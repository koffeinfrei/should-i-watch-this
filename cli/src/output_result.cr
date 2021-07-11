class OutputResult
  getter movie : Movie
  getter links
  property error : String | Nil

  def initialize(@movie)
    @links = {} of Symbol => String | Nil
  end
end
