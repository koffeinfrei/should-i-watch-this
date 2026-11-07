require "./base_output_renderer"

class TextOutputRenderer < BaseOutputRenderer
  def render_error
    <<-DOC
      😢  #{error}

      DOC
  end

  def render_success(recommendation)
    <<-DOC
         year:             #{movie.year}
         director:         #{movie.director}
         actors:           #{movie.actors}
         #{output_trailer}


         🍅  Rotten Tomatoes

             score:        #{movie.score[:rotten_tomatoes]}
             audience:     #{movie.score[:rotten_tomatoes_audience]}

         🎬  IMDb

             rating:       #{movie.score[:imdb]}

         📈  Metacritic

             score:        #{movie.score[:metacritic]}



         Should I watch this?

             #{recommendation.emoji}  #{recommendation.text}
      #{output_links}
      DOC
  end

  def output_links
    return unless show_links?

    output = [] of String

    output << "\n\n"
    output << "   Need more info? Maybe check some reviews?\n"

    links.each do |_key, value|
      output << "       ⟶  #{value}"
    end

    output << ""

    output.join("\n")
  end

  def output_trailer
    return unless movie.trailer_url

    "\n   trailer:          #{movie.trailer_url}\n"
  end
end
