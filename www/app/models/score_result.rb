class ScoreResult
  attr_reader :movie
  attr_accessor :error
  attr_accessor :scores
  attr_accessor :trailer_url

  def initialize(movie)
    @movie = movie
    @scores = {}
  end
end
