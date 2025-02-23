require "./movie"
require "./progress"
require "./configuration"
require "./text_output_renderer"
require "./score_fetcher"

class Lookup
  getter progress : Progress
  getter movie : Movie
  getter score_fetcher : ScoreFetcher
  getter? show_links : Bool

  def initialize(title_or_imdb_id, @show_links = false, year = nil)
    @movie = Movie.parse(title_or_imdb_id)
    @movie.year = year if year

    @progress = Progress.new(movie)

    @score_fetcher = ScoreFetcher.new(@movie, Configuration.new.key)
  end

  def run(renderer, show_progress = true)
    if show_progress
      spawn do
        progress.start
      end
    end

    result = score_fetcher.run

    output = renderer.new(result, show_links?).run

    if show_progress
      progress.stop(output)
    else
      puts output
    end
  end
end
