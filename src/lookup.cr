require "./movie"
require "./progress"
require "./configuration"
require "./text_output"
require "./score_fetcher"

class Lookup
  getter progress : Progress
  getter movie : Movie
  getter score_fetcher : ScoreFetcher
  getter show_links : Bool

  def initialize(title, @show_links = false, year = nil)
    @movie = Movie.new(title)
    @movie.year = year if year

    @progress = Progress.new(movie)

    @score_fetcher = ScoreFetcher.new(@movie, Configuration.new.key)
  end

  def run
    spawn do
      progress.start
    end

    score_fetcher.run

    output = TextOutput.new(score_fetcher.movie, score_fetcher.links, show_links)

    progress.stop(
      output.run(score_fetcher.error)
    )
  end
end
