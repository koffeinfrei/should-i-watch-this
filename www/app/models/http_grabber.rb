class HttpGrabber
  def initialize(url)
    @url = url
  end

  def run(selector)
    agent = Mechanize.new
    agent.user_agent_alias = "Mac Safari"
    agent.read_timeout = 5
    agent.open_timeout = 5

    page = agent.get(@url)
    page.search(selector).first.content
  rescue Mechanize::ResponseCodeError, Net::ReadTimeout, Net::OpenTimeout => e
    Rails.logger.error("event=http_grabber_error error=#{e.inspect}")
    nil
  end
end
