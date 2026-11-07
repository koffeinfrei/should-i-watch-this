class OutputResult
  getter movie : Movie
  getter links
  property error : String?

  def initialize(@movie)
    @links = {} of Symbol => String?
  end
end
