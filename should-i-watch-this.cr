require "json"

require "crest"
require "myhtml"
require "emoji"
require "cli"
require "string_inflection"
require "inflector/core_ext"

class Fetcher
  SPINNER_CHARACTERS = %w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

	@title : String

  def initialize(title : String)
    @title = title.titleize
  end

  def html(url)
    html = Crest.get(url).body

    Myhtml::Parser.new(html)
  end

  def css(html, expression)
    html.css(expression).first.inner_text.strip.gsub(/[^0-9.]/, "")
  end

  def progress(text)
    while
      0.upto(SPINNER_CHARACTERS.size - 1) do |index|
        STDOUT << "\r"
        STDOUT << "#{SPINNER_CHARACTERS[index]}  #{text}"
        sleep 0.1
      end
    end
  end

  def run
    channels = {
      progress: Channel(Nil).new,
      imdb: Channel(Nil).new,
      tomato: Channel(Nil).new
    }

    score = {} of Symbol => Float64 | Int32

    spawn do
      # omdb
      json = Crest.get(
        "http://www.omdbapi.com/",
        params: { :t => @title, :apikey => "af8f7bfb" }
      ).body
      omdb = JSON.parse(json)
      imdb_id = omdb["imdbID"]

      # metacritic from omdb
      score[:meta] = omdb["Metascore"].to_s.to_i

      # imdb
      # we scrape the score from the imdb website, as the value in omdb is not
      # really up-to-date
      imdb_html = html("https://www.imdb.com/title/#{imdb_id}")
      score[:imdb] = css(imdb_html, %{[itemprop="ratingValue"]}).to_f

      channels[:imdb].send(nil)
    end

    # tomato
    spawn do
      tomato_html = html("https://www.rottentomatoes.com/m/#{StringInflection.snake(@title)}")

      score[:tomato] = css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage").to_i
      score[:tomato_audience] = css(tomato_html, ".audience-score .mop-ratings-wrap__percentage").to_i

      channels[:tomato].send(nil)
    end

    progress_text = "Fetching movie '#{@title}'"
    done_text = "Movie '#{@title}':"

    spawn do
      progress(progress_text)
      channels[:imdb].receive
      channels[:tomato].receive

      channels[:progress].send(nil)
    end

    channels[:progress].receive

    recommendation_text, recommendation_emoji =
      if score[:imdb] > 7 && score[:tomato] > 70 && score[:tomato_audience] > 70 && score[:meta] > 70
        ["Go ahead, you'll probably enjoy this!", ":+1:"]
      elsif score[:imdb] < 5 && score[:tomato] > 50 && score[:tomato_audience] > 50 && score[:meta] > 50
        ["Be prepared for something aweful.", ":-1:"]
      else
        ["Not sure, you may fall asleep.", ":zzz:"]
      end

    puts <<-DOC
    \r   Movie 'Captive State' #{" " * (progress_text.size - done_text.size)}

       #{Emoji.emojize(":tomato:")}  Rotten Tomatoes

           score:        #{score[:tomato]}%
           audience:     #{score[:tomato_audience]}%

       #{Emoji.emojize(":clapper:")}  IMDb

           rating:       #{score[:imdb]}/10

       #{Emoji.emojize(":chart_with_upwards_trend:")}  Metacritic

           score:        #{score[:meta]}/100



       Should I watch this?

           #{Emoji.emojize(recommendation_emoji)}  #{recommendation_text}


    DOC
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
