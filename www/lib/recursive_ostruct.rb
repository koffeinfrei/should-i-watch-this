require "ostruct"

module RecursiveOstruct
  def self.from(hash)
    hash.each_with_object(OpenStruct.new) do |(key, val), memo|
      memo[key] = val.is_a?(Hash) ? from(val) : val
    end
  end
end
