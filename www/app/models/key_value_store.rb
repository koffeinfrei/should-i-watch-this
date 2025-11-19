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

  def self.set_json(key, value, **)
    client.set(key, Oj.dump(value), **)
  end

  def self.get_json(key)
    value = client.get(key)
    if value
      Oj.load(value)
    end
  end

  def self.delete_all(pattern)
    client.scan_each(match: pattern) do |key|
      client.del(key)
    end
  end
end
