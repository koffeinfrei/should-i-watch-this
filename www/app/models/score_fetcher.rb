class ScoreFetcher
  def initialize(movie, sources)
    @movie = movie
    @result = {}
    @sources = Array(sources)
  end

  def run
    @sources.map do |source|
      Thread.new { send("fetch_#{source}") }
    end.each(&:join)

    @result
  end

  private

  def fetch_imdb
    url = @movie.imdb_url
    return unless url

    if html = HttpGrabber::Selenium.new(url, tor: true).run('script[type="application/ld+json"]')
      data = JSON.parse(html)

      if score = data.dig("aggregateRating", "ratingValue")
        @result[:imdb] = parse_score(score)
      end

      @result[:trailer_url] = data.dig("trailer", "embedUrl")
    else
      Log.error(:fetch_imdb_failed, wiki_id: @movie.wiki_id, url: url)
    end
  end

  def fetch_metacritic
    url = @movie.metacritic_url
    return unless url

    if html = HttpGrabber::Curl.new(url).run('script[type="application/ld+json"]')
      data = JSON.parse(html)

      if score = data.dig("aggregateRating", "ratingValue")
        @result[:metacritic] = parse_score(score)
      end
    else
      Log.error(:fetch_metacritic_failed, wiki_id: @movie.wiki_id, url: url)
    end
  end

  def fetch_rotten_tomatoes
    url = @movie.rotten_url
    return unless url

    if html = HttpGrabber::Curl.new(url).run("#media-scorecard-json")
      data = JSON.parse(html)

      if critics_score = data.dig("criticsScore", "scorePercent")
        @result[:rotten_tomatoes] = parse_score(critics_score)
      end

      if audience_score = data.dig("audienceScore", "scorePercent")
        @result[:rotten_tomatoes_audience] = parse_score(audience_score)
      end
    else
      Log.error(:fetch_rotten_tomatoes_failed, wiki_id: @movie.wiki_id, url: url)
    end
  end

  # no-op, `#fetch_rotten_tomatoes` fetches both
  def fetch_rotten_tomatoes_audience; end

  def parse_score(value)
    unless value.to_s&.include?("N/A")
      value.to_d
    end
  end
end
