class HttpGrabber
  def initialize(url)
    @url = url
  end

  def run(selector)
    response = Curl.get(@url) do |http|
      http.connect_timeout = 5
      http.timeout = 5
      http.follow_location = true
    end
    page = Nokogiri::HTML(response.body_str)
    page.at_css(selector)&.content
  rescue StandardError => e
    Rails.logger.error("event=http_grabber_error url=\"#{@url}\" error=\"#{e.inspect}\"")
    nil
  end
end
