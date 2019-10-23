require "./movie"
require "./recommender"

abstract class BaseOutputRenderer
  getter movie : Movie
  getter links : Hash(Symbol, String | Nil)
  getter show_links : Bool
  getter error : String | Nil

  def initialize(@movie, @links, @show_links, @error)
  end

  def run
    if error
      render_error
    else
      render_success(Recommender.new(movie).run)
    end
  end

  abstract def render_error
  abstract def render_success(recommendation)
end
