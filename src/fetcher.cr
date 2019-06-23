require "json"

require "crest"
require "myhtml"
require "string_inflection"
require "inflector/core_ext"

require "./movie"
require "./progress"
require "./score"
require "./configuration"
require "./recommender"
require "./recommendation"
require "./result_output"

class Fetcher
  OMDB_TO_TOMATO_TYPE_MAP = {
    "movie"  => "m",
    "series" => "tv",
  }

  getter omdb_api_key : String
  getter movie : Movie
  getter channels
  getter links
  getter progress : Progress
  property error : String | Nil
  property result_output : ResultOutput

  def initialize(title, show_links = false)
    @movie = Movie.new(title)

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

  def html(url)
    html = Crest.get(url).body

    Myhtml::Parser.new(html)
  end

  def css(html, expression)
    elements = html.css(expression)

    return nil if elements.size == 0

    elements.first.inner_text.strip
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
    omdb = {} of String => JSON::Any
    begin
      json = Crest.get(
        "http://www.omdbapi.com/",
        params: {
          :t      => movie.title,
          :apikey => omdb_api_key,
        }
      ).body
      omdb = JSON.parse(json)
    rescue e : Crest::Unauthorized
      abort("The OMDB API refused our request. It seems like your OMDB API key is not valid.")
    end

    if omdb["Response"] == "False"
      abort("Could not fetch information about the movie. Did you misspell it?")
    end

    movie.title = omdb["Title"].as_s
    movie.imdb_id = omdb["imdbID"].as_s
    movie.year = omdb["Year"].as_s
    movie.director = omdb["Director"].as_s
    movie.actors = omdb["Actors"].as_s
    movie.type = omdb["Type"].as_s

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
    url = "https://www.imdb.com/title/#{movie.imdb_id}"
    imdb_html = html(url)
    movie.score[:imdb] = DecimalScore.new(
      css(imdb_html, %{[itemprop="ratingValue"]})
    )

    links[:imdb] = url
  end

  # try to scrape the score from the rotten tomatoes website, as the value in
  # omdb is not really up-to-date
  def fetch_tomato
    underscored_title = StringInflection.snake(
      movie.title.tr("àäéèëöü", "aaeeeou").gsub(/[^\w]/, ' ')
    )
    url = "https://www.rottentomatoes.com/#{OMDB_TO_TOMATO_TYPE_MAP[movie.type]}/#{underscored_title}"
    tomato_html = html(url)

    movie.score[:tomato] = PercentageScore.new(
      css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage")
    )
    movie.score[:tomato_audience] = PercentageScore.new(
      css(tomato_html, ".audience-score .mop-ratings-wrap__percentage")
    )

    links[:tomato] = url
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
