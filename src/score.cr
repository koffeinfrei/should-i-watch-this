abstract class Score
  RANGE = {
    good: (0.7..1),
    bad:  (0...0.7),
  }

  getter raw_value : String | Nil
  getter suffix : String

  def initialize(@raw_value, @suffix = "")
  end

  def good?
    within_range?(:good)
  end

  def bad?
    within_range?(:bad)
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

  private def within_range?(type)
    _value = value

    return false if _value.nil?

    RANGE[type].includes?(_value.to_f / max_value)
  end
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
