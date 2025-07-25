require "mechanize"
require "uri"
require "fileutils"

def as_proper_date(date)
  return unless date

  # unknown month / day is represented as `00`, which is an invalid date
  date = date.gsub("-00", "-01")
  Date.parse(date)
end

desc "Update the movie database"
namespace :movies do
  desc "(1) Download the wiki data dump"
  task :download_data do
    output_dir = ENV.fetch("DIR")

    `curl -O https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.json.bz2 --output-dir #{output_dir}`
  end

  desc "(2) Decompress the downloaded wiki data dump"
  task :decompress_data do
    output_dir = ENV.fetch("DIR")

    `(cd #{output_dir} && lbzip2 -d latest-all.json.bz2)`
  end

  desc "(3) Generate the movies file"
  task :generate_movies do
    output_dir = ENV.fetch("DIR")
    input_file = File.join(output_dir, "latest-all.json")
    output_file = File.join(output_dir, "movies.json")
    claim_file = Rails.root.join("config/wikibase-dump-filter-movies-claim")

    `cat #{input_file} | wikibase-dump-filter --claim #{claim_file} > #{output_file}`
  end

  desc "(4) Generate the humans file"
  task :generate_humans do
    output_dir = ENV.fetch("DIR")
    input_file = File.join(output_dir, "latest-all.json")
    output_file = File.join(output_dir, "humans.json")

    `cat #{input_file} | wikibase-dump-filter --claim P31:Q5 > #{output_file}`
  end

  desc "(5) Generate the minimized humans file"
  task :generate_humans_minimized do
    output_dir = ENV.fetch("DIR")
    input_file = File.join(output_dir, "humans.json")
    output_file = File.join(output_dir, "humans-min.json")

    `cat #{input_file} | jq -c '[.id, .labels.mul.value, .labels.en.value, .labels["en-us"].value]' > #{output_file}`
  end

  desc "(6) Import movies from a wikidata json dump"
  task import: [:environment] do
    output_dir = ENV.fetch("DIR")

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
        title = json.dig("labels", "en", "value") || json.dig("labels", "en-us", "value")
        title_original = json.dig("claims", "P1476", 0, "mainsnak", "datavalue", "value", "text")
        imdb_id = json.dig("claims", "P345", 0, "mainsnak", "datavalue", "value")
        rotten_id = json.dig("claims", "P1258", 0, "mainsnak", "datavalue", "value")
        metacritic_id = json.dig("claims", "P1712", 0, "mainsnak", "datavalue", "value")
        omdb_id = json.dig("claims", "P3302", 0, "mainsnak", "datavalue", "value")

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
          title_normalized: MovieRecord.normalize(title),
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

      MovieRecord.upsert_all(attributes, unique_by: :wiki_id)

      print "."
    end

    puts "\nGenerating tsv columns..."
    ActiveRecord::Base.connection.execute <<~SQL.squish
      update movie_records
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
  end

  namespace :fetch_posters do
    desc "(7) Fetch movie posters from imdb"
    task imdb: [:environment] do
      agent = Mechanize.new
      agent.user_agent_alias = "Mac Safari"
      agent.read_timeout = 5
      agent.open_timeout = 5

      out_dir = Rails.root.join("public/posters")
      out_dir_100 = Rails.root.join("public/posters/100")
      out_dir_300 = Rails.root.join("public/posters/300")
      log_none = Rails.root.join("tmp/fetch_posters_imdb_none")
      log_errors = Rails.root.join("tmp/fetch_posters_imdb_errors")

      FileUtils.touch(log_none) unless File.exist?(log_none)
      FileUtils.mkdir_p(out_dir_300)
      FileUtils.mkdir_p(out_dir_100)

      no_poster_input = File.readlines(log_none).map(&:strip)

      records =
        if ENV["FAILED_ONLY"]
          puts "Re-fetching failed...\n"
          error_input = File.readlines(log_errors).map(&:strip)
          MovieRecord.where(wiki_id: error_input)
        else
          puts "Fetching all...\n"
          existing = Dir.glob(Rails.root.join("public/posters/*")).map { File.basename(_1, ".jpg") }
          MovieRecord.order("random()").where.not(imdb_id: nil).where.not(wiki_id: existing)
        end

      error_output = File.new(log_errors, "w")
      no_poster_output = File.new(log_none, "a")

      records.where.not(wiki_id: no_poster_input).find_each do |movie|
        wiki_id = movie.wiki_id

        imdb_id = movie.imdb_id
        page = agent.get("https://www.imdb.com/title/#{imdb_id}")
        url = URI(page.search("meta[property='og:image']").first[:content])
        filename = url.path.split("/").last

        if filename == "imdb_logo.png"
          print "X"
          no_poster_output.puts wiki_id
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
        `convert -resize 100x #{target_path} #{out_dir.join("100/#{wiki_id}.jpg")}`
        `convert -resize 300x #{target_path} #{out_dir.join("300/#{wiki_id}.jpg")}`

        print "."
      rescue Mechanize::ResponseCodeError, Net::ReadTimeout, Net::OpenTimeout => error
        print "F"
        pp ["Get failed", { wiki_id:, imdb_id:, error: error }]
        error_output.puts wiki_id
        next
      end
    end
  end
end
