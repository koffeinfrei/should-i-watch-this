require "http/request"
require "should-i-watch-this/http_user_interface"

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
    HttpUserInterface.new.run(request)
  end
end
