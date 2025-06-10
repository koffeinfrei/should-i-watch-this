class HttpGrabber
  def initialize(url, errors)
    @url = url
    @errors = {
      timeout: ""
    }.merge(errors)
  end

  def run(selector, abort)
    agent = Mechanize.new
    agent.user_agent_alias = "Mac Safari"
    agent.read_timeout = 5
    agent.open_timeout = 5

    page = agent.get(@url)
    page.search(selector).first.content
  # TODO: ResponseCodeError separate?
  rescue Mechanize::ResponseCodeError, Net::ReadTimeout, Net::OpenTimeout
    abort.call(@errors[:timeout])
  end
end
