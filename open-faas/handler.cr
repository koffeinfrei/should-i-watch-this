require "json"
require "http/request"
require "http/headers"
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
  def run(request : HTTP::Request)
    if request.method == "OPTIONS"
      respond_with_cors_preflight(request)
    else
      respond_with_movie(request)
    end
  end

  def respond_with_movie(request)
    params = request.query_params
    headers = request.headers

    show_links = params["show_links"]? == "true"
    year = params["year"]?

    body = request.body.try(&.gets_to_end) || ""
    movie = Movie.new(body)
    movie.year = year if year

    omdb_token = headers["X-Auth-Token"]
    score_fetcher = ScoreFetcher.new(movie, omdb_token)
    score_fetcher.run

    content_type = headers.fetch("Accept", "text/plain")
    renderer =
      if content_type == "application/json"
        JsonOutput
      else
        TextOutput
      end

    movie = renderer.new(
      score_fetcher.movie, score_fetcher.links, show_links
    ).run(score_fetcher.error)

    {
      body:    movie,
      headers: HTTP::Headers{
        "Content-Type"                => content_type,
        "Access-Control-Allow-Origin" => "*",
      },
    }
  end

  def respond_with_cors_preflight(request)
    {
      headers: HTTP::Headers{
        "Allow"                        => "POST, GET, OPTIONS",
        "Access-Control-Allow-Methods" => "POST, GET, OPTIONS",
        "Access-Control-Allow-Origin"  => "*",
        "Access-Control-Allow-Headers" => "X-Auth-Token, Accept",
      },
      status_code: 204,
    }
  end
end
