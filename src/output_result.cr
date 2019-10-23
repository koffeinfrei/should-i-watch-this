class OutputResult
  getter movie : Movie
  getter links
  property error : String | Nil

  def initialize(@movie)
    @links = {
      :imdb            => nil,
      :rotten_tomatoes => nil,
    } of Symbol => String | Nil
  end
end
