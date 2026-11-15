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
    def initialize(url, tor: false)
      @url = url
      @tor = tor
    end

    def run(css_selector)
      content = nil

      begin
        selenium = HttpClient::Selenium.new(tor: @tor)
        content = selenium.inner_html(@url, css_selector)
      rescue StandardError => error
        Log.error(:http_grabber_error, error, url: @url, type: :selenium)
      ensure
        selenium.client.quit
      end

      content
    end
  end
end
