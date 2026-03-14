module HttpGrabber
  class Curl
    def initialize(url)
      @url = url
    end

    def run(selector)
      response = ::Curl.get(@url) do |http|
        http.connect_timeout = 5
        http.timeout = 5
        http.follow_location = true
        http.headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        http.headers["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0"
      end
      page = Nokogiri::HTML(response.body_str)
      page.at_css(selector)&.content
    rescue StandardError => e
      Rails.logger.tagged(Time.now.iso8601(4)) { Rails.logger.error("event=http_grabber_error url=\"#{@url}\" error=\"#{e.inspect}\"") }
      nil
    end
  end

  class Selenium
    def initialize(url)
      @url = url
    end

    def run(selector)
      options = ::Selenium::WebDriver::Options.chrome
      options.add_argument("--headless=new")
      options.add_argument("user-agent=mozilla/5.0 (x11; ubuntu; linux x86_64; rv:147.0) gecko/20100101 firefox/147.0")
      options.timeouts = {
        page_load: 5_000, # 5 seconds
        script: 5_000     # 5 seconds
      }
      options.page_load_strategy = :none
      driver = ::Selenium::WebDriver.for(:chrome, options: options)

      driver.get(@url)

      wait = ::Selenium::WebDriver::Wait.new(timeout: 5)
      element = wait.until { driver.find_element(css: 'script[type="application/ld+json"]') }
      content = element.attribute("innerHTML")

      driver.quit

      content
    rescue StandardError => e
      Rails.logger.tagged(Time.now.iso8601(4)) { Rails.logger.error("event=http_grabber_error url=\"#{@url}\" error=\"#{e.inspect}\"") }
      nil
    end
  end
end
