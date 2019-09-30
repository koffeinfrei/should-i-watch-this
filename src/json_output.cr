require "json"
require "emoji"

require "./recommender"

class JsonOutput
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
    JSON.build do |json|
      json.object do
        json.field "error", error
      end
    end
  end

  def output_success
    recommendation = Recommender.new(movie).run

    JSON.build do |json|
      json.object do
        json.field "title", movie.title
        json.field "year", movie.year
        json.field "director", movie.director
        json.field "actors", movie.actors

        json.field "scores" do
          json.object do
            json.field "rotten_tomatoes" do
              json.object do
                json.field "score", movie.score[:tomato].to_s
                json.field "audience", movie.score[:tomato_audience].to_s
              end
            end

            json.field "imdb" do
              json.object do
                json.field "rating", movie.score[:imdb].to_s
              end
            end

            json.field "metacritic" do
              json.object do
                json.field "score", movie.score[:meta].to_s
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
              json.array do
                links.reject { |_key, value| value.nil? }.each do |_key, value|
                  json.string value
                end
              end
            end
          end
        end
      end
    end
  end
end
