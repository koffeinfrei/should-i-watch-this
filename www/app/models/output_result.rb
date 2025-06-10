class OutputResult
  attr_reader :movie
  attr_accessor :error
  attr_accessor :scores

  def initialize(movie)
    @movie = movie
    @scores = {}
  end
end
