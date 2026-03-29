module HttpClient
  TIMEOUT = 5

  class Curl
    def content(url, css_selector)
      response = ::Curl.get(url) do |http|
        http.connect_timeout = TIMEOUT
        http.timeout = TIMEOUT
        http.follow_location = true
        http.headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        http.headers["User-Agent"] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0"
      end
      page = Nokogiri::HTML(response.body_str)
      page.at_css(css_selector)&.content
    end
  end

  class Selenium
    def content(url, css_selector)
      client.get(url)
      element(url, css_selector).attribute("content")
    end

    def inner_html(url, css_selector)
      element(url, css_selector).attribute("innerHTML")
    end

    def element(url, css_selector)
      client.get(url)
      wait = ::Selenium::WebDriver::Wait.new(timeout: TIMEOUT)
      wait.until { client.find_element(css: css_selector) }
    end

    def client
      @client ||=
        begin
          options = ::Selenium::WebDriver::Options.chrome
          options.add_argument("--headless=new")
          options.add_argument("user-agent=mozilla/5.0 (x11; ubuntu; linux x86_64; rv:147.0) gecko/20100101 firefox/147.0")
          options.timeouts = {
            page_load: TIMEOUT * 1000,
            script: TIMEOUT * 1000
          }
          options.page_load_strategy = :none
          ::Selenium::WebDriver.for(:chrome, options: options)
        end
    end
  end

  class Mechanize
    def download(url, path)
      client.get(url).save(path)
    end

    def client
      @client ||=
        begin
          mechanize = ::Mechanize.new
          mechanize.user_agent_alias = "Mac Safari"
          mechanize.read_timeout = TIMEOUT
          mechanize.open_timeout = TIMEOUT
          mechanize
        end
    end
  end
end
