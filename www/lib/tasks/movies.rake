require "mechanize"
require "uri"

desc "Update the movie database"
namespace :movies do
  # TODO: include
  #   1. downloading full dump
  #   2. transformation with `wikibase_dump_filter`
  desc "Import movies from a wikidata json dump"
  task import: [:environment] do
    file = File.new("./tmp/latest-film-subcategories.json")
    file.each_line do |line|
      json = JSON.parse(line)

      wiki_id = json.dig("id")
      title = json.dig("labels", "en", "value")
      description = json.dig("descriptions", "en", "value")
      imdb_id = json.dig("claims", "P345", 0, "mainsnak", "datavalue", "value")
      rotten_id = json.dig("claims", "P1258", 0, "mainsnak", "datavalue", "value")
      metacritic_id = json.dig("claims", "P1712", 0, "mainsnak", "datavalue", "value")
      omdb_id = json.dig("claims", "P3302", 0, "mainsnak", "datavalue", "value")

      # for films
      release_date = json.dig("claims", "P577", 0, "mainsnak", "datavalue", "value", "time")
      # for shows
      release_date ||= json.dig("claims", "P580", 0, "mainsnak", "datavalue", "value", "time")
      if release_date
        # unknown month / day is represented as `00`, which is an invalid date
        release_date = release_date.gsub("-00", "-01")
        release_date = Date.parse(release_date)
      end

      movie = MovieRecord::Raw.find_or_initialize_by(wiki_id: wiki_id)
      new_record = movie.new_record?
      has_changes = movie.changed?
      saved = movie.update(
        title: title,
        description: description,
        imdb_id: imdb_id,
        rotten_id: rotten_id,
        metacritic_id: metacritic_id,
        omdb_id: omdb_id,
        release_date: release_date,
        raw: json
      )
      if saved
        if new_record
          print "."
        elsif has_changes
          print "U"
        else
          print "S"
        end
      else
        pp(["failed", movie.errors.messages, { wiki_id:, title:, imdb_id:, rotten_id:, metacritic_id:, release_date: }])
      end
    end
  end

  task fetch_posters: [:environment] do
    agent = Mechanize.new
    agent.user_agent_alias = "Mac Safari"
    agent.read_timeout = 5
    agent.open_timeout = 5

    MovieRecord.order("random()").where.not(omdb_id: nil).find_each do |movie|
      wiki_id = movie.wiki_id
      target_path = Rails.root.join("public/posters/#{wiki_id}.jpg")
      if File.exist?(target_path)
        print "S"
        next
      end

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

      if tmp_path != target_path
        `convert #{tmp_path} #{target_path}`
        FileUtils.rm tmp_path
      end

      print "."
    rescue Mechanize::ResponseCodeError, Net::ReadTimeout => error
      print "E"
      pp ["Get failed", { wiki_id:, omdb_id:, error: error }]
      next
    end
  end
end
