require "./movie"
require "./progress"
require "./configuration"
require "./text_output_renderer"
require "./score_fetcher"

class Lookup
  getter progress : Progress
  getter movie : Movie
  getter score_fetcher : ScoreFetcher
  getter show_links : Bool

  def initialize(title_or_imdb_id, @show_links = false, year = nil)
    @movie = Movie.parse(title_or_imdb_id)
    @movie.year = year if year

    @progress = Progress.new(movie)

    @score_fetcher = ScoreFetcher.new(@movie, Configuration.new.key)
  end

  def run
    spawn do
      progress.start
    end

    result = score_fetcher.run

    output = TextOutputRenderer.new(result, show_links)

    progress.stop(output.run)
  end
end
