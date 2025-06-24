class ScoreResult
  attr_reader :movie
  attr_accessor :scores
  attr_accessor :trailer_url

  def initialize(movie)
    @movie = movie
    @scores = {}
  end

  def has_score?
    !@scores.values.all?(&:not_defined?)
  end
end
