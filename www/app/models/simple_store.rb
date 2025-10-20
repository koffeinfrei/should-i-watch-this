module SimpleStore
  KEY_PREFIX = "siwt"

  def self.fetch(key)
    key = self.key(key)

    value = REDIS.get(key)
    return value if value

    new_value = yield

    # Only one thread should compute + set
    REDIS.set(key, new_value, nx: true)

    # Return whichever value ended up stored
    REDIS.get(key)
  end

  def self.delete(key)
    key = self.key(key)

    REDIS.del(key)
  end

  def self.key(key)
    "#{KEY_PREFIX}_#{key}"
  end
end
