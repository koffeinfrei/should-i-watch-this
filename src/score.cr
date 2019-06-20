class Score
  getter value : Float64 | Int32 | Nil
  getter is_percentage : Bool
  getter suffix : String

  def initialize(@value, @is_percentage = true, @suffix = "")
  end

  def good?
    value && percentage_value > 70
  end

  def bad?
    value && percentage_value < 50
  end

  def percentage_value
    if is_percentage
      value || 0
    else
      (value || 0) * 10
    end
  end

  def to_s(io)
    io <<
      if value
        "#{value}#{suffix}"
      else
        "N/A"
      end
  end
end
