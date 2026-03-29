module HttpGrabber
  class Curl
    def initialize(url)
      @url = url
    end

    def run(css_selector)
      HttpClient::Curl.new.content(@url, css_selector)
    rescue StandardError => e
      Rails.logger.tagged(Time.now.iso8601(4)) { Rails.logger.error("event=http_grabber_error url=\"#{@url}\" error=\"#{e.inspect}\"") }
      nil
    end
  end

  class Selenium
    def initialize(url)
      @url = url
    end

    def run(css_selector)
      selenium = HttpClient::Selenium.new
      content = selenium.inner_html(@url, css_selector)
      selenium.client.quit
      content
    rescue StandardError => e
      Rails.logger.tagged(Time.now.iso8601(4)) { Rails.logger.error("event=http_grabber_error url=\"#{@url}\" error=\"#{e.inspect}\"") }
      nil
    end
  end
end
