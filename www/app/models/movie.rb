module Movie
  KEY_PREFIX = "siwt_movie"
  CLI_BIN = ENV.fetch("CLI_BIN", "should-i-watch-this")

  class Error < StandardError; end

  def self.get!(title, year)
    if json = load(title, year)
      RecursiveOstruct.from(json)
    else
      json = fetch(title, year)

      if error = json["error"]
        Rails.logger.error("event=movie_fetch_error error=#{error.inspect}")
        raise Error.new(error)
      end

      save(json)
      RecursiveOstruct.from(json)
    end
  end

  def self.get_local(title, year)
    if json = load(title, year)
      RecursiveOstruct.from(json)
    end
  end

  def self.search!(query)
    IO.popen([CLI_BIN, "lookup", "-f", "json", query, "-l", err: [:child, :out]]) do |io|
      output = io.read
      json = JSON.parse(output)

      if error = json["error"]
        Rails.logger.error("event=movie_search_error error=#{error.inspect}")
        raise Error.new(error)
      end

      save(json)
      RecursiveOstruct.from(json)
    end
  end

  def self.save(json)
    REDIS.set(key(json["title"], json["year"]), json.to_json, ex: 1.day)
  end

  def self.load(title, year)
    value = REDIS.get(key(title, year))
    if value
      JSON.parse(value)
    end
  end

  def self.fetch(title, year)
    IO.popen([CLI_BIN, "lookup", "-f", "json", title, "-y", year, "-l", err: [:child, :out]]) do |io|
      output = io.read
      JSON.parse(output)
    end
  end

  def self.key(title, year)
    "#{KEY_PREFIX}_#{title.parameterize.underscore}_#{year}"
  end
end
