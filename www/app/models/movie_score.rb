class MovieScore < ApplicationRecord
  SOURCES = [:imdb, :rotten_tomatoes, :rotten_tomatoes_audience, :metacritic]

  belongs_to :movie

  def imdb
    if imdb_value
      Score::Decimal.new(imdb_value, "/10")
    elsif movie.imdb_id
      Score::Incomplete.new
    else
      Score::Missing.new
    end
  end

  def rotten_tomatoes
    if rotten_tomatoes_value
      Score::Percentage.new(rotten_tomatoes_value, "%")
    elsif movie.rotten_id
      Score::Incomplete.new
    else
      Score::Missing.new
    end
  end

  def rotten_tomatoes_audience
    if rotten_tomatoes_audience_value
      Score::Percentage.new(rotten_tomatoes_audience_value, "%")
    elsif movie.rotten_id
      Score::Incomplete.new
    else
      Score::Missing.new
    end
  end

  def metacritic
    if metacritic_value
      Score::Percentage.new(metacritic_value, "/100")
    elsif movie.metacritic_id
      Score::Incomplete.new
    else
      Score::Missing.new
    end
  end

  def recent?
    complete? || updated_at&.after?(5.minutes.ago)
  end

  def complete?
    incomplete_sources.empty?
  end

  def incomplete_sources
    SOURCES.filter_map do |platform|
      score = send(platform)
      if score.incomplete?
        platform
      end
    end
  end

  def scores
    SOURCES.map { send(_1) }
  end

  def self.get(movie, fetch: true)
    record = find_or_initialize_by(movie: movie)

    if record.recent? || !fetch
      record
    else
      result = ScoreFetcher.new(movie, record.incomplete_sources).run
      # `compact`: Don't overwrite existing values on update
      record.assign_attributes(result.compact.slice(*MovieScore::SOURCES).to_h { ["#{_1}_value", _2] })
      # TODO: add `trailer_url` is somewhat hacked in here
      record.trailer_url = result[:trailer_url] if result[:trailer_url]
      record.save
      record
    end
  end
end
