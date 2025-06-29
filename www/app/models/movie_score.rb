module MovieScore
  KEY_PREFIX = "siwt_movie"
  STD_TTL = 1.day

  def self.get!(wiki_id)
    if scores = load(wiki_id)
      scores
    else
      result = fetch(wiki_id)

      ttl =
        if result.incomplete?
          5.seconds
        else
          STD_TTL
        end

      # TODO: the `trailer_url` is somewhat hacked in here
      save(wiki_id, result.scores, result.trailer_url, ttl: ttl)

      [result.scores, result.trailer_url]
    end
  end

  def self.get_local(wiki_id)
    load(wiki_id)
  end

  def self.save(wiki_id, scores, trailer_url, ttl: STD_TTL)
    REDIS.set(key(wiki_id), Oj.dump([scores, trailer_url]), ex: ttl)
  end

  def self.load(wiki_id)
    value = REDIS.get(key(wiki_id))
    if value
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
