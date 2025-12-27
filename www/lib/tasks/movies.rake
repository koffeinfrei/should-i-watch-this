require "mechanize"
require "uri"
require "fileutils"

def as_proper_date(date)
  return unless date

  # unknown month / day is represented as `00`, which is an invalid date
  date = date.gsub("-00", "-01")
  Date.parse(date)
end

def parse_external_reference(json, id)
  json.dig("claims", id, 0).yield_self do |claim|
    break unless claim

    deprecated = claim.dig("qualifiers", "P2241")
    unless deprecated
      claim.dig("mainsnak", "datavalue", "value")
    end
  end
end

def instrument(task)
  task_name = task.to_s.underscore

  Rails.logger.tagged(Time.now.iso8601(4)) do
    Rails.logger.info("event=rake_#{task_name}_start")
  end

  success = yield
  if success
    Rails.logger.info("✅ #{task} succeeded.")
  else
    Rails.logger.error("❌ #{task} failed. Abort.")
  end

  Rails.logger.tagged(Time.now.iso8601(4)) do
    Rails.logger.info("event=rake_#{task_name}_stop")
  end
end

def movies_claim_file = Rails.root.join("config/wikibase-dump-filter-movies-claim")
def humans_claim = "Q5"
def all_claims
  movies = File.read(movies_claim_file).strip.split(":").last.split(",")
  [humans_claim] + movies
end

def output_dir = ENV.fetch("DIR")

desc "Update the movie database"
namespace :movies do
  desc "(1) Download the wiki data dump"
  task download: [:environment] do
    instrument(:download) do
      system "curl --fail -O https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.json.bz2 --output-dir #{output_dir}"
    end
  end

  desc "(2) Decompress the downloaded wiki data dump"
  task decompress: [:environment] do
    instrument(:decompress) do
      system "(cd #{output_dir} && lbzcat latest-all.json.bz2 | rg '(#{all_claims.map { "\"#{_1}\"" }.join("|")})' > latest-all-reduced.json)"
    end
  end

  desc "(3) Generate the movies file"
  task generate_movies: [:environment] do
    instrument(:generate_movies) do
      input_file = File.join(output_dir, "latest-all-reduced.json")
      output_file = File.join(output_dir, "movies.json")

      system %Q(cat #{input_file} | parallel --pipe --block 100M --line-buffer "npx wikibase-dump-filter --claim #{movies_claim_file}" > #{output_file})
    end
  end

  desc "(4) Generate the humans file"
  task generate_humans: [:environment] do
    instrument(:generate_humans) do
      input_file = File.join(output_dir, "latest-all-reduced.json")
      output_file = File.join(output_dir, "humans.json")

      system %Q(cat #{input_file} | parallel --pipe --block 100M --line-buffer "npx wikibase-dump-filter --claim P31:#{humans_claim}" > #{output_file})
    end
  end

  desc "(5) Generate the minimized humans file"
  task generate_humans_minimized: [:environment] do
    instrument(:generate_humans_minimized) do
      input_file = File.join(output_dir, "humans.json")
      output_file = File.join(output_dir, "humans-min.json")

      system %Q(cat #{input_file} | jq -c '[.id, .labels.mul.value, .labels.en.value, .labels["en-us"].value]' > #{output_file})
    end
  end

  desc "(6) Import movies from a wikidata json dump"
  task import: [:environment] do
    instrument(:import) do
      series_classes = File.readlines(Rails.root.join("config/wikidata_series_classes")).map(&:strip)

      puts "Reading humans..."
      file = File.new(File.join(output_dir, "humans-min.json"))
      humans = file.each.map do |line|
        json = JSON.parse(line)
        [
          json[0],
          json[1] || json[2] || json[3]
        ]
      end.to_h

      puts "Inserting movies..."
      file = File.new(File.join(output_dir, "movies.json"))
      file.lazy.each_slice(10_000) do |lines|
        attributes = lines.map do |line|
          json = JSON.parse(line)

          instance = json.dig("claims", "P31", 0, "mainsnak", "datavalue", "value", "id")
          series = instance.in?(series_classes)

          wiki_id = json.dig("id")

          # Select the "preferred" entry if available
          titles_json = json.dig("claims", "P1476")
          title_original = titles_json&.find { _1["rank"] == "preferred" }&.dig("mainsnak", "datavalue", "value", "text") ||
            titles_json&.dig(0, "mainsnak", "datavalue", "value", "text") ||
            json.dig("labels")&.values&.first&.dig("value")

          title = json.dig("labels", "en", "value") ||
            json.dig("labels", "en-us", "value") ||
            json.dig("labels", "mul", "value") ||
            json.dig("labels", 0, "value") ||
            title_original

          imdb_id = parse_external_reference(json, "P345")
          rotten_id = parse_external_reference(json, "P1258")
          metacritic_id = parse_external_reference(json, "P1712")
          omdb_id = parse_external_reference(json, "P3302")

          directors = (json.dig("claims", "P57") || []).map { _1.dig("mainsnak", "datavalue", "value", "id") }
          actors = (json.dig("claims", "P161") || []).take(3).map { _1.dig("mainsnak", "datavalue", "value", "id") }

          # for films
          release_date = as_proper_date(json.dig("claims", "P577", 0, "mainsnak", "datavalue", "value", "time"))
          # for shows (mostly)
          start_date = json.dig("claims", "P580", 0, "mainsnak", "datavalue", "value", "time")
          end_date = json.dig("claims", "P582", 0, "mainsnak", "datavalue", "value", "time")

          {
            wiki_id: wiki_id,
            title: title,
            title_normalized: Movie.normalize(title),
            title_original: title_original,
            imdb_id: imdb_id,
            rotten_id: rotten_id,
            metacritic_id: metacritic_id,
            omdb_id: omdb_id,
            series: series,
            release_date: start_date || release_date,
            end_date: end_date,
            directors: directors.map { humans[_1] }.compact,
            actors: actors.map { humans[_1] }.compact
          }
        end

        Movie.upsert_all(attributes, unique_by: :wiki_id)

        print "."
      end

      puts "\nGenerating tsv columns..."
      ActiveRecord::Base.connection.execute <<~SQL.squish
      update movies
        set
          tsv_title = to_tsvector(
            'pg_catalog.simple',
            lower(coalesce(title_normalized,''))
          ),
          tsv_title_original = to_tsvector(
            'pg_catalog.simple',
            lower(coalesce(title_original,''))
          );
      SQL

      SimpleStore.delete("movie_count")
    end
  end

  namespace :fetch_posters do
    desc "(7) Fetch movie posters from imdb"
    task imdb: [:environment] do
      agent = Mechanize.new
      agent.user_agent_alias = "Mac Safari"
      agent.read_timeout = 5
      agent.open_timeout = 5

      out_dir = Rails.root.join("public/posters/original")
      out_dir_100 = Rails.root.join("public/posters/100")
      out_dir_300 = Rails.root.join("public/posters/300")
      log_none = Rails.root.join("system/fetch_posters_imdb_none")
      log_errors = Rails.root.join("system/fetch_posters_imdb_errors")

      FileUtils.touch(log_none) unless File.exist?(log_none)
      FileUtils.mkdir_p(out_dir_100)
      FileUtils.mkdir_p(out_dir_300)

      no_posters = File.readlines(log_none).map(&:strip)
      errors = File.readlines(log_errors).map(&:strip)
      # discard movies that don't have an imdb id anymore
      errors = errors & Movie.where(wiki_id: errors).where.not(imdb_id: nil).pluck(:wiki_id)

      records =
        if ENV["FAILED_ONLY"]
          puts "Re-fetching failed...\n"
          Movie.where(wiki_id: errors)
        else
          puts "Fetching all...\n"
          existing = Dir.glob(Rails.root.join(out_dir, "*.jpg")).map { File.basename(_1, ".jpg") }
          all = Movie.where.not(imdb_id: nil).pluck(:wiki_id)
          remaining = all - existing
          Movie.where(wiki_id: remaining).order("random()")
        end

      records.where.not(wiki_id: no_posters).find_each do |movie|
        wiki_id = movie.wiki_id

        imdb_id = movie.imdb_id
        page = agent.get("https://www.imdb.com/title/#{imdb_id}")
        url = URI(page.search("meta[property='og:image']").first[:content])
        filename = url.path.split("/").last

        if filename == "imdb_logo.png"
          print "X"
          no_posters << wiki_id
          next
        end
        pp ["Different type", wiki_id, url] unless filename =~ /(\.jpg)|(.jpeg)$/

        tmp_path = out_dir.join(filename)
        agent.get(url).save(tmp_path)

        target_path = out_dir.join("#{wiki_id}.jpg")

        if tmp_path != target_path
          `convert #{tmp_path} #{target_path}`
          FileUtils.rm tmp_path
        end
        `convert -resize 100x #{target_path} #{out_dir_100.join("#{wiki_id}.jpg")}`
        `convert -resize 300x #{target_path} #{out_dir_300.join("#{wiki_id}.jpg")}`

        print "."
        errors.delete(wiki_id)
      rescue Mechanize::ResponseCodeError, Net::ReadTimeout, Net::OpenTimeout => error
        print "F"
        pp ["Get failed", { wiki_id:, imdb_id:, error: error }]
        errors << wiki_id
        next
      end
    ensure
      puts
      File.open(log_errors, "w") do |file|
        file.puts(errors.sort.uniq)
      end
      File.open(log_none, "w") do |file|
        file.puts(no_posters.sort.uniq)
      end
    end
  end
end
