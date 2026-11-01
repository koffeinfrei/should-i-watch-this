module HttpGrabber
  class Curl
    def initialize(url)
      @url = url
    end

    def run(css_selector)
      HttpClient::Curl.new.content(@url, css_selector)
    rescue StandardError => error
      Log.error(:http_grabber_error, error, url: @url, type: :curl)
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
    rescue StandardError => error
      Log.error(:http_grabber_error, error, url: @url, type: :selenium)
      nil
    end
  end
end
