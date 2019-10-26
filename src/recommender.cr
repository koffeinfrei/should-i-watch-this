require "./score"
require "./recommendation"

class Recommender
  getter score : Hash(Symbol, Score)

  def initialize(@score)
  end

  def run
    text, emoji =
      if no_rating?
        ["Hmm, there's no rating about this at all...", ":question:"]
      elsif unanimously_excellent?
        ["Watch this right now, this is really excellent!", ":star2:"]
      elsif unanimously_good? || good_or_excellent?
        ["Go ahead, you'll probably enjoy this!", ":+1:"]
      elsif unanimously_average?
        ["This seems to be a fine watch, but it probably won't change your life.", ":partly_sunny:"]
      elsif unanimously_bad?
        ["Be prepared for something awful.", ":-1:"]
      else
        ["Not sure. You may fall asleep, or you may be delighted.", ":confused:"]
      end

    Recommendation.new(text, emoji)
  end

  def no_rating?
    score.values.all?(&.not_defined?)
  end

  def unanimously_excellent?
    score.values.all? do |score|
      score.excellent? || score.not_defined?
    end
  end

  def unanimously_good?
    score.values.all? do |score|
      score.good? || score.not_defined?
    end
  end

  def unanimously_average?
    score.values.all? do |score|
      score.average? || score.not_defined?
    end
  end

  def unanimously_bad?
    score.values.all? do |score|
      score.bad? || score.not_defined?
    end
  end

  def good_or_excellent?
    score.values.all? do |score|
      score.excellent? || score.good? || score.not_defined?
    end
  end
end
