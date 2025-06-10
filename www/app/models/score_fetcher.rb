class ScoreFetcher
  def initialize(movie)
    @result = OutputResult.new(movie)
  end

  def run
    [
      Thread.new { fetch_imdb },
      Thread.new { fetch_rotten_tomatoes },
      Thread.new { fetch_metacritic }
    ].each(&:join)

    missing_scores!

    @result
  end

  def fetch_imdb
    return unless @result.movie.imdb_url

    html = HttpGrabber.new(@result.movie.imdb_url, timeout: "IMDb unreachable.").run('script[type="application/ld+json"]', method(:abort))
    data = JSON.parse(html)

    score = data.dig("aggregateRating", "ratingValue")
    if score
      @result.scores[:imdb] = Score.create("#{score.to_f}/10", Score::Decimal)
    end

    # TODO: add to result and store in redis
    @result.movie.trailer_url = data.dig("trailer", "embedUrl")
  rescue => e
    abort("IMDb fetch failed: #{e.message}")
  end

  def fetch_metacritic
    return unless @result.movie.metacritic_url

    html = HttpGrabber.new(@result.movie.metacritic_url, timeout: "Metacritic unreachable.").run('script[type="application/ld+json"]', method(:abort))
    data = JSON.parse(html)

    score = data.dig("aggregateRating", "ratingValue")
    if score
      @result.scores[:metacritic] = Score.create("#{score.to_f}/100", Score::Percentage)
    end
  rescue => e
    abort("Metacritic fetch failed: #{e.message}")
  end

  def fetch_rotten_tomatoes
    return unless @result.movie.rotten_id

    html = HttpGrabber.new(@result.movie.rotten_url, timeout: "Rotten Tomatoes unreachable.").run("#media-scorecard-json", method(:abort))
    data = JSON.parse(html)

    critics_score = data.dig("criticsScore", "score")
    if critics_score
      score = "#{critics_score}%"
      @result.scores[:rotten_tomatoes] = Score.create(score, Score::Percentage)
    end

    audience_score = data.dig("audienceScore", "score")
    if audience_score
      score = "#{audience_score}%"
      @result.scores[:rotten_tomatoes_audience] = Score.create(score, Score::Percentage)
    end
  rescue => e
    abort("Rotten Tomatoes fetch failed: #{e.message}")
  end

  def missing_scores!
    [:imdb, :rotten_tomatoes, :rotten_tomatoes_audience, :metacritic].each do |key|
      @result.scores[key] ||= Score::Missing.new
    end
  end

  def abort(message)
    @result.error ||= message
  end
end
