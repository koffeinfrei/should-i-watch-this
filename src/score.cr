require "./score_value"

abstract class Score
  THRESHOLDS = {
    excellent: 0.8,
    good:      0.7,
    average:   0.50,
  }

  getter score_value : ScoreValue

  delegate suffix, to: @score_value

  def initialize(raw_value)
    @score_value = ScoreValue.new(raw_value)
  end

  def excellent?
    above_threshold?(:excellent)
  end

  def good?
    above_threshold?(:good)
  end

  def average?
    above_threshold?(:average)
  end

  def bad?
    below_threshold?(:average)
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

  private def above_threshold?(type)
    with_scaled_value?(type) do |scaled_value|
      scaled_value >= THRESHOLDS[type]
    end
  end

  private def below_threshold?(type)
    with_scaled_value?(type) do |scaled_value|
      scaled_value < THRESHOLDS[type]
    end
  end

  private def with_scaled_value?(type)
    _value = value

    return false if _value.nil?

    scaled_value = _value.to_f / max_value

    yield scaled_value
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
