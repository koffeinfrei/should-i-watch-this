require "json"

require "crest"
require "myhtml"

abstract class HttpGrabber
  getter url : String
  getter errors : NamedTuple(unauthorized: String, timeout: String)

  def initialize(@url, errors)
    @errors = {
      unauthorized: "",
      timeout:      "",
    }.merge(errors)
  end

  def run(abort, params = {} of Symbol => String)
    client = HTTP::Client.new(URI.parse(url))
    client.read_timeout = 10.seconds
    request = Crest::Request.new(
      :get,
      url,
      params: params,
      http_client: client
    )

    parse_body(request.execute.body)
  rescue IO::TimeoutError
    abort.call(errors[:unauthorized])
    parse_body
  rescue Crest::Unauthorized
    abort.call(errors[:timeout])
    parse_body
  end

  abstract def parse_body(body)
end

class HtmlHttpGrabber < HttpGrabber
  def parse_body(body = "")
    Myhtml::Parser.new(body)
  end
end

class JsonHttpGrabber < HttpGrabber
  def parse_body(body = "{}")
    JSON.parse(body)
  end
end
