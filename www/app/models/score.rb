class Score
  THRESHOLDS = {
    excellent: 0.8,
    good:      0.7,
    average:   0.50
  }

  delegate :suffix, to: :@score_value

  def initialize(raw_value)
    @score_value = Value.new(raw_value)
  end

  def self.create(value, target_class)
    if value.nil? || value.include?("N/A")
      Missing.new
    else
      target_class.new(value)
    end
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
    @score_value.value.nil?
  end

  def missing?
    false
  end

  def incomplete?
    false
  end

  def to_s
    if value
      "#{value}#{suffix}"
    else
      "N/A"
    end
  end

  private

  def above_threshold?(type)
    with_scaled_value?(type) do |scaled_value|
      scaled_value >= THRESHOLDS[type]
    end
  end

  def below_threshold?(type)
    with_scaled_value?(type) do |scaled_value|
      scaled_value < THRESHOLDS[type]
    end
  end

  def with_scaled_value?(type, &)
    return false if value.nil?

    scaled_value = value.to_f / max_value

    yield scaled_value
  end

  class Value
    attr_reader :value
    attr_reader :suffix

    def initialize(raw_value)
      if raw_value
        value_parts = raw_value.match(/^([0-9\.]+)(.*)$/)
        if value_parts
          @value = value_parts[1]
          @suffix = value_parts[2]
        end
      end
    end
  end

  class Missing < Score
    def initialize
      super(nil)
    end

    def max_value
      0
    end

    def value
      @score_value.value
    end

    def missing?
      true
    end
  end

  # When not all sources could be successfully fetched
  class Incomplete < Missing
    def incomplete?
      true
    end
  end

  class Decimal < Score
    def max_value
      10
    end

    def value
      @score_value.value&.to_f
    end
  end

  class Percentage < Score
    def max_value
      100
    end

    def value
      @score_value.value&.to_i
    end
  end
end
