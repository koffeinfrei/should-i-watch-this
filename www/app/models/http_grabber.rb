class HttpGrabber
  def initialize(url)
    @url = url
  end

  def run(selector)
    response = Curl.get(@url) do |http|
      http.connect_timeout = 5
      http.timeout = 5
      http.follow_location = true
      http.headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      http.headers["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0"
    end
    page = Nokogiri::HTML(response.body_str)
    page.at_css(selector)&.content
  rescue StandardError => e
    Rails.logger.error("event=http_grabber_error url=\"#{@url}\" error=\"#{e.inspect}\"")
    nil
  end
end
