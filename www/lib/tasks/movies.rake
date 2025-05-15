require "mechanize"
require "uri"

desc "Update the movie database"
namespace :movies do
  # TODO: include
  #   1. downloading full dump
  #   2. transformation with `wikibase_dump_filter`
  desc "Import movies from a wikidata json dump"
  task import: [:environment] do
    puts "Reading humans..."
    file = File.new(ENV.fetch("HUMANS_INPUT_FILE"))
    humans = file.each.map do |line|
      json = JSON.parse(line)
      [
        json[0],
        json[1] || json[2] || json[3]
      ]
    end.to_h

    puts "Inserting movies..."
    file = File.new(ENV.fetch("INPUT_FILE"))
    file.lazy.each_slice(10_000) do |lines|
      attributes = lines.map do |line|
        json = JSON.parse(line)

        wiki_id = json.dig("id")
        title = json.dig("labels", "en", "value") || json.dig("labels", "en-us", "value")
        title_original = json.dig("claims", "P1476", 0, "mainsnak", "datavalue", "value", "text")
        description = json.dig("descriptions", "en", "value")
        imdb_id = json.dig("claims", "P345", 0, "mainsnak", "datavalue", "value")
        rotten_id = json.dig("claims", "P1258", 0, "mainsnak", "datavalue", "value")
        metacritic_id = json.dig("claims", "P1712", 0, "mainsnak", "datavalue", "value")
        omdb_id = json.dig("claims", "P3302", 0, "mainsnak", "datavalue", "value")

        directors = (json.dig("claims", "P57") || []).map { _1.dig("mainsnak", "datavalue", "value", "id") }
        actors = (json.dig("claims", "P161") || []).take(3).map { _1.dig("mainsnak", "datavalue", "value", "id") }

        # for films
        release_date = json.dig("claims", "P577", 0, "mainsnak", "datavalue", "value", "time")
        # for shows
        release_date ||= json.dig("claims", "P580", 0, "mainsnak", "datavalue", "value", "time")
        if release_date
          # unknown month / day is represented as `00`, which is an invalid date
          release_date = release_date.gsub("-00", "-01")
          release_date = Date.parse(release_date)
        end

        {
          wiki_id: wiki_id,
          title: title,
          title_normalized: title && I18n.transliterate(title).downcase,
          title_original: title_original,
          description: description,
          imdb_id: imdb_id,
          rotten_id: rotten_id,
          metacritic_id: metacritic_id,
          omdb_id: omdb_id,
          release_date: release_date,
          directors: directors.map { humans[_1] },
          actors: actors.map { humans[_1] }
        }
      end

      MovieRecord.upsert_all(attributes, unique_by: :wiki_id)

      print "."
    end

    puts "Generating tsv columns..."
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

  task fetch_posters: [:environment] do
    agent = Mechanize.new
    agent.user_agent_alias = "Mac Safari"
    agent.read_timeout = 5
    agent.open_timeout = 5

    error_output = File.new("./tmp/fetch_posters_errors", "w")
    existing = Dir.glob(Rails.root.join("public/posters/*")).map { File.basename(_1, ".jpg") }
    MovieRecord.order("random()").where.not(omdb_id: nil).where.not(wiki_id: existing).find_each do |movie|
      wiki_id = movie.wiki_id

      omdb_id = movie.omdb_id
      page = agent.get("https://www.omdb.org/en/us/movie/#{omdb_id}")
      image = page.images_with(id: "left_image").first
      url = image.uri
      filename = url.path.split("/").last

      if filename == "no_cover185px.png"
        print "X"
        next
      end
      pp ["Different type", wiki_id, url] unless filename =~ /(\.jpg)|(.jpeg)$/

      tmp_path = Rails.root.join("public/posters/#{filename}")
      image.fetch.save!(tmp_path)

      target_path = Rails.root.join("public/posters/#{wiki_id}.jpg")

      if tmp_path != target_path
        `convert #{tmp_path} #{target_path}`
        FileUtils.rm tmp_path
      end

      print "."
    rescue Mechanize::ResponseCodeError, Net::ReadTimeout => error
      print "F"
      pp ["Get failed", { wiki_id:, omdb_id:, error: error }]
      error_output.puts wiki_id
      next
    end
  end
end
