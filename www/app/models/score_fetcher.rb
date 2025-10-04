class ScoreFetcher
  def initialize(movie)
    @result = ScoreResult.new(movie)
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

  private

  def fetch_imdb
    url = @result.movie.imdb_url
    return unless url

    if html = HttpGrabber.new(url).run('script[type="application/ld+json"]')
      data = JSON.parse(html)

      if score = data.dig("aggregateRating", "ratingValue")
        @result.scores[:imdb] = Score.create("#{score.to_f}/10", Score::Decimal)
      end

      @result.trailer_url = data.dig("trailer", "embedUrl")
    else
      @result.scores[:imdb] = Score::Incomplete.new
      Rails.logger.error("event=fetch_imdb_failed wiki_id=#{@result.movie.wiki_id} url=\"#{url}\"")
    end
  end

  def fetch_metacritic
    url = @result.movie.metacritic_url
    return unless url

    if html = HttpGrabber.new(url).run('script[type="application/ld+json"]')
      data = JSON.parse(html)

      if score = data.dig("aggregateRating", "ratingValue")
        @result.scores[:metacritic] = Score.create("#{score.to_f}/100", Score::Percentage)
      end
    else
      @result.scores[:metacritic] = Score::Incomplete.new
      Rails.logger.error("event=fetch_metacritic_failed wiki_id=#{@result.movie.wiki_id} url=\"#{url}\"")
    end
  end

  def fetch_rotten_tomatoes
    url = @result.movie.rotten_url
    return unless url

    if html = HttpGrabber.new(url).run("#media-scorecard-json")
      data = JSON.parse(html)

      if critics_score = data.dig("criticsScore", "score")
        score = "#{critics_score}%"
        @result.scores[:rotten_tomatoes] = Score.create(score, Score::Percentage)
      end

      if audience_score = data.dig("audienceScore", "score")
        score = "#{audience_score}%"
        @result.scores[:rotten_tomatoes_audience] = Score.create(score, Score::Percentage)
      end
    else
      @result.scores[:rotten_tomatoes] = Score::Incomplete.new
      @result.scores[:rotten_tomatoes_audience] = Score::Incomplete.new
      Rails.logger.error("event=fetch_rotten_tomatoes_failed wiki_id=#{@result.movie.wiki_id} url=\"#{url}\"")
    end
  end

  def missing_scores!
    [:imdb, :rotten_tomatoes, :rotten_tomatoes_audience, :metacritic].each do |key|
      @result.scores[key] ||= Score::Missing.new
    end
  end
end
