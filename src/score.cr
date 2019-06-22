require "./score_value"

abstract class Score
  RANGE = {
    excellent: (0.8..1),
    good:      (0.7..0.79),
    average:   (0.51..0.69),
    bad:       (0..0.5),
  }

  getter score_value : ScoreValue

  delegate suffix, to: @score_value

  def initialize(raw_value)
    @score_value = ScoreValue.new(raw_value)
  end

  def excellent?
    within_range?(:excellent)
  end

  def good?
    within_range?(:good)
  end

  def average?
    within_range?(:average)
  end

  def bad?
    within_range?(:bad)
  end

  def not_defined?
    score_value.value.nil?
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

class MissingScore < Score
  def initialize
    super(nil)
  end

  def max_value
    0
  end

  def value
    score_value.value
  end
end

class DecimalScore < Score
  def max_value
    10
  end

  def value : Float64 | Nil
    score_value.value.try(&.to_f)
  end
end

class PercentageScore < Score
  def max_value
    100
  end

  def value : Int32 | Nil
    score_value.value.try(&.to_i)
  end
end
