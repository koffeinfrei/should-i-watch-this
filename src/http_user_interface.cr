require "json"
require "http/request"
require "http/headers"
require "./movie"
require "./score_fetcher"
require "./text_output_renderer"
require "./json_output_renderer"

class HttpUserInterface
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
    movie = Movie.parse(body)
    movie.year = year if year

    omdb_token = headers["X-Auth-Token"]
    result = ScoreFetcher.new(movie, omdb_token).run

    content_type = headers.fetch("Accept", "text/plain")
    renderer =
      if content_type == "application/json"
        JsonOutputRenderer
      else
        TextOutputRenderer
      end

    movie = renderer.new(result, show_links).run

    {
      body:    "#{movie}\n",
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
