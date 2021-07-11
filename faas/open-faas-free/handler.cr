require "http/request"
require "should-i-watch-this/http_user_interface"

# Provides an OpenFaaS function for should-i-watch-this, without the need to
# provide a `X-Auth-Token`.
#
# See open-faas/handler.cr
class Handler
  def run(request : HTTP::Request)
    request.headers["X-Auth-Token"] = File.read("/var/openfaas/secrets/omdb-token")

    HttpUserInterface.new.run(request)
  end
end
