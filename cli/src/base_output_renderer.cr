require "./movie"
require "./recommender"
require "./output_result"

abstract class BaseOutputRenderer
  getter output_result : OutputResult
  getter show_links : Bool

  delegate movie, to: @output_result
  delegate links, to: @output_result
  delegate error, to: @output_result

  def initialize(@output_result, @show_links)
  end

  def run
    if error
      render_error
    else
      render_success(Recommender.new(movie.score).run)
    end
  end

  abstract def render_error
  abstract def render_success(recommendation)
end
