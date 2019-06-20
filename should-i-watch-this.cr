require "json"

require "crest"
require "myhtml"
require "emoji"
require "cli"
require "string_inflection"
require "inflector/core_ext"

class Progress
  SPINNER_CHARACTERS = %w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

  getter movie : Movie

  def initialize(@movie)
  end

  def start
    show_spinner
  end

  def stop(result_text)
    puts <<-DOC
      \r   Movie '#{@movie.title}' #{" " * (progress_text.size - done_text.size)}

      #{result_text}


      DOC
  end

  def progress_text
    "Fetching movie '#{@movie.title}'"
  end

  def done_text
    "Movie '#{@movie.title}':"
  end

  def show_spinner
    while
      0.upto(SPINNER_CHARACTERS.size - 1) do |index|
        STDOUT << "\r"
        STDOUT << "#{SPINNER_CHARACTERS[index]}  #{progress_text}"
        sleep 0.1
      end
    end
  end
end

class Score
  getter value : Float64 | Int32 | Nil
  getter is_percentage : Bool
  getter suffix : String

  def initialize(@value, @is_percentage = true, @suffix = "")
  end

  def good?
    @value && percentage_value > 70
  end

  def bad?
    @value && percentage_value < 50
  end

  def percentage_value
    if @is_percentage
      @value || 0
    else
      (@value || 0) * 10
    end
  end

  def to_s(io)
    io <<
      if @value
        "#{@value}#{@suffix}"
      else
        "N/A"
      end
  end
end

class Movie
  property title : String
  property imdb_id : String = ""
  property year : String = ""
  property director : String = ""
  property actors : String = ""

  getter score = {} of Symbol => Score

  def initialize(title)
    @title = title.titleize
  end
end

class Fetcher
  getter movie : Movie

  def initialize(title)
    @movie = Movie.new(title)
  end

  def html(url)
    html = Crest.get(url).body

    Myhtml::Parser.new(html)
  end

  def css(html, expression)
    html.css(expression).first.inner_text.strip.gsub(/[^0-9.]/, "")
  end

  def run
    progress = Progress.new(@movie)

    channels = {
      progress: Channel(Nil).new,
      omdb: Channel(Nil).new,
      imdb: Channel(Nil).new,
      tomato: Channel(Nil).new
    }

    error = nil

    spawn do
      # omdb
      json = Crest.get(
        "http://www.omdbapi.com/",
        params: { :t => @movie.title, :apikey => "af8f7bfb" }
      ).body
      omdb = JSON.parse(json)

      if omdb["Response"] == "False"
        error = json["Error"]

        # cancel all requests
        channels.each_value do |channel|
          channel.send(nil)
        end
      end

      @movie.title = omdb["Title"].as_s
      @movie.imdb_id = omdb["imdbID"].as_s
      @movie.year = omdb["Year"].as_s
      @movie.director = omdb["Director"].as_s
      @movie.actors = omdb["Actors"].as_s

      # metacritic from omdb
      meta_score = omdb["Metascore"].to_s
      @movie.score[:meta] = Score.new(
        if meta_score == "N/A"
          nil
        else
          meta_score.to_i
        end,
        suffix: "/100"
      )

      channels[:omdb].send(nil) # unblock main
      channels[:omdb].send(nil) # unblock imdb
      channels[:omdb].send(nil) # unblock tomato
    end

    # imdb
    # we scrape the score from the imdb website, as the value in omdb is not
    # really up-to-date
    spawn do
      channels[:omdb].receive

      imdb_html = html("https://www.imdb.com/title/#{@movie.imdb_id}")
      @movie.score[:imdb] = Score.new(
        css(imdb_html, %{[itemprop="ratingValue"]}).to_f,
        is_percentage: false,
        suffix: "/10"
      )

      channels[:imdb].send(nil)
    end

    # tomato
    spawn do
      channels[:omdb].receive

      underscored_title = StringInflection.snake(
        @movie.title.gsub(/[^\w]/, ' ')
      )
      url = "https://www.rottentomatoes.com/m/#{underscored_title}"
      tomato_html = html(url)

      @movie.score[:tomato] = Score.new(
        css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage").to_i,
        suffix: "%"
      )
      @movie.score[:tomato_audience] = Score.new(
        css(tomato_html, ".audience-score .mop-ratings-wrap__percentage").to_i,
        suffix: "%"
      )

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
      progress.stop <<-DOC
         #{Emoji.emojize(":cry:")}  Could not fetch information about the movie. Did you misspell it?
      DOC
    else
      recommendation_text, recommendation_emoji =
        if @movie.score[:imdb].good? && @movie.score[:tomato].good? && @movie.score[:tomato_audience].good? && @movie.score[:meta].good?
          ["Go ahead, you'll probably enjoy this!", ":+1:"]
        elsif @movie.score[:imdb].bad? && @movie.score[:tomato].bad? && @movie.score[:tomato_audience].bad? && @movie.score[:meta].bad?
          ["Be prepared for something aweful.", ":-1:"]
        else
          ["Not sure, you may fall asleep.", ":zzz:"]
        end

      progress.stop <<-DOC
         year:             #{@movie.year}
         director:         #{@movie.director}
         actors:           #{@movie.actors}



         #{Emoji.emojize(":tomato:")}  Rotten Tomatoes

             score:        #{@movie.score[:tomato]}
             audience:     #{@movie.score[:tomato_audience]}

         #{Emoji.emojize(":clapper:")}  IMDb

             rating:       #{@movie.score[:imdb]}

         #{Emoji.emojize(":chart_with_upwards_trend:")}  Metacritic

             score:        #{@movie.score[:meta]}



         Should I watch this?

             #{Emoji.emojize(recommendation_emoji)}  #{recommendation_text}
      DOC
    end
  end
end

class ShouldIWatchThis < Cli::Command
  class Help
    header "Check the different internets if it's worth watching this movie."
    footer "Made with #{Emoji.emojize(":coffee:")} by Koffeinfrei"
  end

  class Options
    arg "title",
      required: true,
      desc: "The title of the movie"
    help
  end

  def run
    Fetcher.new(args.title).run
  end
end

ShouldIWatchThis.run(ARGV)
