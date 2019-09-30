require "json"
require "should-i-watch-this/movie"
require "should-i-watch-this/score_fetcher"
require "should-i-watch-this/text_output"
require "should-i-watch-this/json_output"

# Provides an OpenFaaS function for should-i-watch-this.
#
# Basic Example (using curl):
#     curl -H 'X-Auth-Token: <your omdb token>' \
#         http://127.0.0.1:8080/function/should-i-watch-this \
#         -d "the terminator"
#
# Example with parameters (using curl):
#     curl -H 'X-Auth-Token: <your omdb token>' \
#         http://127.0.0.1:8080/function/should-i-watch-this?show_links=true\&year=1984 \
#         -d "the terminator"

# Example with json response (using curl):
#     curl -H 'X-Auth-Token: <your omdb token>' \
#         -H "Accept: application/json" \
#         http://127.0.0.1:8080/function/should-i-watch-this?show_links=true\&year=1984 \
#         -d "the terminator"
class Handler
  def run(req : String)
    params = HTTP::Params.parse(ENV.fetch("Http_Query", ""))

    omdb_token = ENV["Http_X_Auth_Token"]

    show_links = params["show_links"]? == "true"
    year = params["year"]?

    movie = Movie.new(req)
    movie.year = year if year

    score_fetcher = ScoreFetcher.new(movie, omdb_token)
    score_fetcher.run

    renderer =
      if ENV["Http_Accept"] == "application/json"
        JsonOutput
      else
        TextOutput
      end

    renderer.new(
      score_fetcher.movie, score_fetcher.links, show_links
    ).run(score_fetcher.error)
  end
end
