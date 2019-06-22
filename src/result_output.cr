require "emoji"

require "./movie"

class ResultOutput
  getter movie : Movie
  getter links : Hash(Symbol, String | Nil)
  getter show_links : Bool

  def initialize(@movie, @links, @show_links)
  end

  def run(error)
    if error
      output_error(error)
    else
      output_success
    end
  end

  def output_error(error)
    <<-DOC
           #{Emoji.emojize(":cry:")}  #{error}

    DOC
  end

  def output_success
    recommendation = Recommender.new(movie).run

    <<-DOC
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
    #{output_links}
    DOC
  end

  def output_links
    return unless show_links

    output = [] of String

    output << "\n\n"
    output << "   Need more info? Maybe check some reviews?\n"

    links.reject { |_key, value| value.nil? }.each do |_key, value|
      output << "       ⟶  #{value}"
    end

    output << ""

    output.join("\n")
  end
end
