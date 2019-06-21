abstract class Score
  GOOD_THRESHOLD = 0.7
  BAD_THRESHOLD  = 0.5

  getter raw_value : String | Nil
  getter suffix : String

  def initialize(@raw_value, @suffix = "")
  end

  def good?
    value.try(&.> (GOOD_THRESHOLD * max_value))
  end

  def bad?
    value.try(&.< (BAD_THRESHOLD * max_value))
  end

  def not_defined?
    raw_value.nil?
  end

  def to_s(io)
    io <<
      if value
        "#{value}#{suffix}"
      else
        "N/A"
      end
  end

  abstract def max_value

  abstract def value
end

class DecimalScore < Score
  def max_value
    10
  end

  def value : Float64 | Nil
    raw_value.try(&.to_f)
  end
end

class PercentageScore < Score
  def max_value
    100
  end

  def value : Int32 | Nil
    raw_value.try(&.to_i)
  end
end
