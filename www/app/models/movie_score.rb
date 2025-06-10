module MovieScore
  KEY_PREFIX = "siwt_movie"

  class Error < StandardError; end

  def self.get!(wiki_id)
    if scores = load(wiki_id)
      scores
    else
      result = fetch(wiki_id)

      if result.error
        Rails.logger.error("event=movie_fetch_error error=#{result.error.inspect}")
        raise Error.new(result.error)
      end

      save(wiki_id, result.scores)
      result.scores
    end
  end

  def self.get_local(wiki_id)
    load(wiki_id)
  end

  def self.save(wiki_id, scores)
    REDIS.set(key(wiki_id), Oj.dump(scores), ex: 1.day)
  end

  def self.load(wiki_id)
    value = REDIS.get(key(wiki_id))
    if value
      movie = MovieRecord.new
      Oj.load(value)
    end
  end

  def self.fetch(wiki_id)
    movie = MovieRecord.find_by(wiki_id: wiki_id)
    ScoreFetcher.new(movie).run
  end

  def self.key(wiki_id)
    "#{KEY_PREFIX}_#{wiki_id}"
  end
end
