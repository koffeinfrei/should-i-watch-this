require "http/client"
require "http/request"

class Handler
  def run(request : HTTP::Request)
    function_host = ENV["SHOULD_I_WATCH_THIS_SERVICE_HOST"]
    function_port = ENV["SHOULD_I_WATCH_THIS_SERVICE_PORT"]

    headers = request.headers.dup
    headers["X-Auth-Token"] = File.read("/var/openfaas/secrets/omdb-token")

    response = HTTP::Client.post(
      URI.parse("http://#{function_host}:#{function_port}?#{request.query}"),
      body: request.body,
      headers: headers
    )

    {
      body:        response.body,
      status_code: response.status_code,
      headers:     response.headers,
    }
  end
end
