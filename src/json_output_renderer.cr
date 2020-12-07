require "json"
require "emoji"

require "./base_output_renderer"

class JsonOutputRenderer < BaseOutputRenderer
  def render_error
    JSON.build do |json|
      json.object do
        json.field "error", error
      end
    end
  end

  def render_success(recommendation)
    JSON.build do |json|
      json.object do
        json.field "title", movie.title
        json.field "year", movie.year
        json.field "director", movie.director
        json.field "actors", movie.actors
        json.field "poster_url", movie.poster_url

        json.field "scores" do
          json.object do
            json.field "rotten_tomatoes" do
              json.object do
                json.field "score", movie.score[:rotten_tomatoes].to_s
                json.field "audience", movie.score[:rotten_tomatoes_audience].to_s
              end
            end

            json.field "imdb" do
              json.object do
                json.field "rating", movie.score[:imdb].to_s
              end
            end

            json.field "metacritic" do
              json.object do
                json.field "score", movie.score[:metacritic].to_s
              end
            end
          end

          json.field "recommendation" do
            json.object do
              json.field "emoji", Emoji.emojize(recommendation.emoji)
              json.field "text", recommendation.text
            end
          end

          if show_links
            json.field "links" do
              json.object do
                links.each do |key, value|
                  json.field key, value
                end
              end
            end
          end
        end
      end
    end
  end
end
