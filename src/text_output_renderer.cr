require "emoji"

require "./base_output_renderer"

class TextOutputRenderer < BaseOutputRenderer
  def render_error
    <<-DOC
           #{Emoji.emojize(":cry:")}  #{error}

    DOC
  end

  def render_success(recommendation)
    <<-DOC
       year:             #{movie.year}
       director:         #{movie.director}
       actors:           #{movie.actors}



       #{Emoji.emojize(":tomato:")}  Rotten Tomatoes

           score:        #{movie.score[:rotten_tomatoes]}
           audience:     #{movie.score[:rotten_tomatoes_audience]}

       #{Emoji.emojize(":clapper:")}  IMDb

           rating:       #{movie.score[:imdb]}

       #{Emoji.emojize(":chart_with_upwards_trend:")}  Metacritic

           score:        #{movie.score[:metacritic]}



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
