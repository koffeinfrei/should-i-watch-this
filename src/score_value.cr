class ScoreValue
  getter value : String | Nil
  getter suffix : String | Nil

  def initialize(raw_value)
    if raw_value
      value_parts = raw_value.match(/^([0-9\.]+)(.*)$/)
      if value_parts
        @value = value_parts[1]?
        @suffix = value_parts[2]?
      end
    end
  end
end
