require "./movie"
require "./http_grabber"
require "./html_text_by_css"

class ScoreFetcher
  OMDB_URL = "https://www.omdbapi.com/"
  IMDB_URL = "https://www.imdb.com"

  getter movie : Movie
  getter omdb_api_key : String
  getter channels
  getter links
  property error : String | Nil

  def initialize(@movie, @omdb_api_key)
    @channels = {
      progress:        Channel(Nil).new,
      omdb:            Channel(Nil).new,
      imdb:            Channel(Nil).new,
      rotten_tomatoes: Channel(Nil).new,
    }

    @links = {
      :imdb            => nil,
      :rotten_tomatoes => nil,
    } of Symbol => String | Nil
  end

  def run
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

      channels[:rotten_tomatoes].send(nil)
    end

    spawn do
      channels[:omdb].receive
      channels[:imdb].receive
      channels[:rotten_tomatoes].receive

      channels[:progress].send(nil)
    end

    channels[:progress].receive

    missing_scores!
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
    movie.poster_url = omdb["Poster"].as_s
    movie.poster_url = nil if movie.poster_url == "N/A"

    # metacritic from omdb
    meta_score = omdb["Metascore"].to_s
    movie.score[:metacritic] = PercentageScore.new(
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
      movie.score[:rotten_tomatoes] = PercentageScore.new(
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

    movie.score[:rotten_tomatoes] = PercentageScore.new(
      html_text_by_css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage")
    )
    movie.score[:rotten_tomatoes_audience] = PercentageScore.new(
      html_text_by_css(tomato_html, ".audience-score .mop-ratings-wrap__percentage")
    )

    links[:rotten_tomatoes] = movie.tomato_url
  rescue Crest::NotFound
  end

  def missing_scores!
    [:imdb, :rotten_tomatoes, :rotten_tomatoes_audience, :metacritic].each do |key|
      unless @movie.score.has_key?(key)
        @movie.score[key] = MissingScore.new
      end
    end
  end

  def abort(error_message)
    self.error = error_message

    # cancel all requests
    channels.each_value do |channel|
      channel.send(nil)
    end
  end
end
