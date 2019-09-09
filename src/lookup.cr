require "json"

require "./movie"
require "./progress"
require "./score"
require "./configuration"
require "./recommender"
require "./recommendation"
require "./result_output"
require "./http_grabber"
require "./html_text_by_css"

class Lookup
  OMDB_URL = "https://www.omdbapi.com/"
  IMDB_URL = "https://www.imdb.com"

  getter omdb_api_key : String
  getter movie : Movie
  getter channels
  getter links
  getter progress : Progress
  property error : String | Nil
  property result_output : ResultOutput

  def initialize(title, show_links = false, year = nil)
    @movie = Movie.new(title)
    @movie.year = year if year

    @channels = {
      progress: Channel(Nil).new,
      omdb:     Channel(Nil).new,
      imdb:     Channel(Nil).new,
      tomato:   Channel(Nil).new,
    }

    @links = {
      :imdb   => nil,
      :tomato => nil,
    } of Symbol => String | Nil

    @progress = Progress.new(movie)

    @omdb_api_key = Configuration.new.key

    @result_output = ResultOutput.new(@movie, @links, show_links)
  end

  def abort(error_message)
    self.error = error_message

    # cancel all requests
    channels.each_value do |channel|
      channel.send(nil)
    end
  end

  def run
    spawn do
      progress.start
    end

    spawn do
      fetch_omdb

      channels[:omdb].send(nil) # unblock main
      channels[:omdb].send(nil) # unblock imdb
      channels[:omdb].send(nil) # unblock tomato
    end

    spawn do
      channels[:omdb].receive

      fetch_imdb

      channels[:imdb].send(nil)
    end

    # tomato
    spawn do
      channels[:omdb].receive

      fetch_tomato

      channels[:tomato].send(nil)
    end

    spawn do
      channels[:omdb].receive
      channels[:imdb].receive
      channels[:tomato].receive

      channels[:progress].send(nil)
    end

    channels[:progress].receive

    missing_scores!

    progress.stop(
      result_output.run(error)
    )
  end

  def fetch_omdb
    omdb = JsonHttpGrabber.new(
      OMDB_URL, {
      timeout: "The OMDb API can't be reached right now. Maybe your " \
               "connection is broken. Or the whole internet is down. Or just " \
               "www.omdbapi.com.",
      unauthorized: "The OMDb API refused our request. It seems like your " \
                    "OMDb API key is not valid.",
    }).run(->abort(String), {
      :t        => movie.title,
      :y        => movie.year,
      :tomatoes => "true",
      :apikey   => omdb_api_key,
    })

    if omdb.try(&.["Response"]) == "False"
      abort("Could not fetch information about the movie. Did you misspell it?")
    end

    movie.title = omdb["Title"].as_s
    movie.year = omdb["Year"].as_s
    movie.director = omdb["Director"].as_s
    movie.actors = omdb["Actors"].as_s
    movie.imdb_id = omdb["imdbID"].as_s
    movie.tomato_url = omdb["tomatoURL"].as_s
    movie.tomato_url = nil if movie.tomato_url == "N/A"

    # metacritic from omdb
    meta_score = omdb["Metascore"].to_s
    movie.score[:meta] = PercentageScore.new(
      if meta_score == "N/A"
        nil
      else
        "#{meta_score}/100"
      end
    )

    # tomato from omdb
    tomato_score = omdb["Ratings"].as_a.find do |rating|
      rating["Source"] == "Rotten Tomatoes"
    end
    if tomato_score
      movie.score[:tomato] = PercentageScore.new(
        tomato_score["Value"].as_s
      )
    end
  end

  # scrape the score from the imdb website, as the value in omdb is not
  # really up-to-date
  def fetch_imdb
    url = "#{IMDB_URL}/title/#{movie.imdb_id}"
    imdb_html = HtmlHttpGrabber.new(url, {
      timeout: "IMDb can't be reached right now. Maybe your connection is " \
               "broken. Or the whole internet is down. Or just www.imdb.com.",
    }).run(->abort(String))

    movie.score[:imdb] = DecimalScore.new(
      html_text_by_css(imdb_html, %{[itemprop="ratingValue"]})
    )

    links[:imdb] = url
  end

  # try to scrape the score from the rotten tomatoes website, as the value in
  # omdb is not really up-to-date
  def fetch_tomato
    url = movie.tomato_url

    return if url.nil?

    tomato_html = HtmlHttpGrabber.new(url, {
      timeout: "Rotten Tomatoes can't be reached right now. Maybe your " \
               "connection is broken. Or the whole internet is down. Or just " \
               "www.rottentomatoes.com.",
    }).run(->abort(String))

    movie.score[:tomato] = PercentageScore.new(
      html_text_by_css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage")
    )
    movie.score[:tomato_audience] = PercentageScore.new(
      html_text_by_css(tomato_html, ".audience-score .mop-ratings-wrap__percentage")
    )

    links[:tomato] = movie.tomato_url
  rescue Crest::NotFound
  end

  def missing_scores!
    [:imdb, :tomato, :tomato_audience, :meta].each do |key|
      unless @movie.score.has_key?(key)
        @movie.score[key] = MissingScore.new
      end
    end
  end
end
