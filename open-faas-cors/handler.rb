require 'net/http'

# TODO document that this is a proxy handler
class Handler
  def run(body, headers)
    function_host = ENV['SHOULD_I_WATCH_THIS_SERVICE_HOST']
    function_port = ENV['SHOULD_I_WATCH_THIS_SERVICE_PORT']
    query_string = headers['rack.request.query_string']
    post_data = headers['rack.request.form_vars']
    content_type = headers['HTTP_ACCEPT']

    response_body = Net::HTTP.post(
      URI.parse("http://#{function_host}:#{function_port}?#{query_string}"),
      post_data,
      'Accept' => content_type,
      'X-Auth-Token' => headers['HTTP_X_AUTH_TOKEN']
    ).body

    response_headers = {
      'Access-Control-Allow-Origin' => '*',
      'Content-Type' => content_type
    }

    [response_body, response_headers]
  end
end
