require "json"

require "crest"
require "myhtml"
require "emoji"
require "cli"
require "string_inflection"
require "inflector/core_ext"

class Progress
  SPINNER_CHARACTERS = %w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

  def initialize(@movie : Movie)
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

class Movie
  getter title : String
  property imdb_id : String = ""

  getter score = {} of Symbol => Float64 | Int32

  def initialize(title)
    @title = title.titleize
  end
end

class Fetcher
  @movie : Movie

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

      @movie.imdb_id = omdb["imdbID"].as_s

      # metacritic from omdb
      @movie.score[:meta] = omdb["Metascore"].to_s.to_i

      # imdb
      # we scrape the score from the imdb website, as the value in omdb is not
      # really up-to-date
      imdb_html = html("https://www.imdb.com/title/#{@movie.imdb_id}")
      @movie.score[:imdb] = css(imdb_html, %{[itemprop="ratingValue"]}).to_f

      channels[:imdb].send(nil)
    end

    # tomato
    spawn do
      tomato_html = html("https://www.rottentomatoes.com/m/#{StringInflection.snake(@movie.title)}")

      @movie.score[:tomato] = css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage").to_i
      @movie.score[:tomato_audience] = css(tomato_html, ".audience-score .mop-ratings-wrap__percentage").to_i

      channels[:tomato].send(nil)
    end

    spawn do
      progress.start

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
        if @movie.score[:imdb] > 7 && @movie.score[:tomato] > 70 && @movie.score[:tomato_audience] > 70 && @movie.score[:meta] > 70
          ["Go ahead, you'll probably enjoy this!", ":+1:"]
        elsif @movie.score[:imdb] < 5 && @movie.score[:tomato] > 50 && @movie.score[:tomato_audience] > 50 && @movie.score[:meta] > 50
          ["Be prepared for something aweful.", ":-1:"]
        else
          ["Not sure, you may fall asleep.", ":zzz:"]
        end

      progress.stop <<-DOC
         #{Emoji.emojize(":tomato:")}  Rotten Tomatoes

             score:        #{@movie.score[:tomato]}%
             audience:     #{@movie.score[:tomato_audience]}%

         #{Emoji.emojize(":clapper:")}  IMDb

             rating:       #{@movie.score[:imdb]}/10

         #{Emoji.emojize(":chart_with_upwards_trend:")}  Metacritic

             score:        #{@movie.score[:meta]}/100



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
  end

  def run
    Fetcher.new(args.title).run
  end
end

ShouldIWatchThis.run(ARGV)
