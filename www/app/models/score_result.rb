class ScoreResult
  attr_reader :movie
  attr_accessor :scores
  attr_accessor :trailer_url

  def initialize(movie)
    @movie = movie
    @scores = {}
  end

  def incomplete?
    @scores.values.any?(&:incomplete?)
  end
end
