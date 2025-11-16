module KeyValueStore
  KEY_PREFIX =
    begin
      prefix = ENV.fetch("APPLICATION_NAME").parameterize.underscore
      if Rails.env.test?
        prefix += "_test"
      end
      prefix
    end

  def self.client
    @client ||= Redis.new
  end
end
