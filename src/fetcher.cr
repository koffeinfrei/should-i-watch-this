require "json"

require "crest"
require "myhtml"
require "emoji"
require "string_inflection"
require "inflector/core_ext"

require "./movie"
require "./progress"
require "./score"
require "./configuration"
require "./recommender"
require "./recommendation"

class Fetcher
  getter omdb_api_key : String
  getter movie : Movie
  getter channels
  getter progress : Progress
  property error : String | Nil

  def initialize(title)
    @movie = Movie.new(title)

    @channels = {
      progress: Channel(Nil).new,
      omdb: Channel(Nil).new,
      imdb: Channel(Nil).new,
      tomato: Channel(Nil).new
    }

    @progress = Progress.new(movie)

    @omdb_api_key = Configuration.new.key
   end

  def html(url)
    html = Crest.get(url).body

    Myhtml::Parser.new(html)
  end

  def css(html, expression)
    html.css(expression).first.inner_text.strip.gsub(/[^0-9.]/, "")
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
      progress.start

      channels[:omdb].receive
      channels[:imdb].receive
      channels[:tomato].receive

      channels[:progress].send(nil)
    end

    channels[:progress].receive

    if error
      output_error
    else
      output_success
    end
  end

  def fetch_omdb
    omdb = {} of String => JSON::Any
    begin
      json = Crest.get(
        "http://www.omdbapi.com/",
        params: {
          :t => movie.title,
          :apikey => omdb_api_key
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

    # metacritic from omdb
    meta_score = omdb["Metascore"].to_s
    movie.score[:meta] = Score.new(
      if meta_score == "N/A"
        nil
      else
        meta_score.to_i
      end,
      suffix: "/100"
    )
  end

  # we scrape the score from the imdb website, as the value in omdb is not
  # really up-to-date
  def fetch_imdb
    imdb_html = html("https://www.imdb.com/title/#{movie.imdb_id}")
    movie.score[:imdb] = Score.new(
      css(imdb_html, %{[itemprop="ratingValue"]}).to_f,
      is_percentage: false,
      suffix: "/10"
    )
  end

  def fetch_tomato
    underscored_title = StringInflection.snake(
      movie.title.gsub(/[^\w]/, ' ')
    )
    url = "https://www.rottentomatoes.com/m/#{underscored_title}"
    tomato_html = html(url)

    movie.score[:tomato] = Score.new(
      css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage").to_i,
      suffix: "%"
    )
    movie.score[:tomato_audience] = Score.new(
      css(tomato_html, ".audience-score .mop-ratings-wrap__percentage").to_i,
      suffix: "%"
    )
  end

  def output_error
    progress.stop <<-DOC
       #{Emoji.emojize(":cry:")}  #{error}
    DOC
  end

  def output_success
    recommendation = Recommender.new(movie).run

    progress.stop <<-DOC
       year:             #{movie.year}
       director:         #{movie.director}
       actors:           #{movie.actors}



       #{Emoji.emojize(":tomato:")}  Rotten Tomatoes

           score:        #{movie.score[:tomato]}
           audience:     #{movie.score[:tomato_audience]}

       #{Emoji.emojize(":clapper:")}  IMDb

           rating:       #{movie.score[:imdb]}

       #{Emoji.emojize(":chart_with_upwards_trend:")}  Metacritic

           score:        #{movie.score[:meta]}



       Should I watch this?

           #{Emoji.emojize(recommendation.emoji)}  #{recommendation.text}
    DOC
  end
end
