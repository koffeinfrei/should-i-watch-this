module SimpleStore
  def self.fetch(key)
    key = self.key(key)

    value = KeyValueStore.client.get(key)
    return value if value

    new_value = yield

    # Only one thread should compute + set
    KeyValueStore.client.set(key, new_value, nx: true)

    # Return whichever value ended up stored
    KeyValueStore.client.get(key)
  end

  def self.delete(key)
    key = self.key(key)

    KeyValueStore.client.del(key)
  end

  def self.key(key)
    "#{KeyValueStore::KEY_PREFIX}:#{key}"
  end
end
