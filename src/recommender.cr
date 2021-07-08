require "./score"
require "./recommendation"

class Recommender
  getter scores : Array(Score)
  getter mostly_count : Int32
  getter half_count : Int32
  getter minor_count : Int32

  def initialize(scores)
    @scores = scores.values.reject(MissingScore)
    @mostly_count = (@scores.size * 0.75).round.to_i
    @half_count = (@scores.size * 0.5).round.to_i
    @minor_count = (@scores.size * 0.25).round.to_i
  end

  def single_score?
    @scores.size == 1
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def run
    text, emoji =
      if no_rating?
        ["Hmm, there's no rating about this at all...", "❓"]
      elsif unanimously_excellent?
        ["You should definitely watch this, this is really excellent!", "🌟"]
      elsif mostly_excellent?
        ["You should watch this, this is probably excellent!", "⭐️"]
      elsif controversially_excellent?
        ["People seem to either love or hate this.", "🔥"]
      elsif half_excellent?
        ["This is definitely worth watching!", "👏"]
      elsif unanimously_good?
        ["Go ahead, you'll most likely enjoy this!", "👍"]
      elsif mostly_good?
        ["Go ahead, you'll probably enjoy this!", "👍"]
      elsif half_good?
        ["You may enjoy this. It could also be boring though.", "👌"]
      elsif unanimously_average?
        ["Meh. This seems to be ok, but it probably won't change your life.", "⛅️"]
      elsif unanimously_bad?
        ["Be prepared for something awful.", "👎"]
      elsif mostly_bad?
        ["Please move along. There's nothing to see here.", "😧"]
      elsif mostly_average_or_bad?
        ["This seems to be rather something that's not actually good.", "😴"]
      else
        ["Not sure. You may fall asleep, or you may be delighted.", "😕"]
      end

    Recommendation.new(text, emoji)
  end

  # ameba:enable Metrics/CyclomaticComplexity

  def no_rating?
    scores.all?(&.not_defined?)
  end

  def unanimously_excellent?
    scores.all?(&.excellent?)
  end

  def mostly_excellent?
    scores.count(&.excellent?) == mostly_count
  end

  def half_excellent?
    scores.count(&.excellent?) == half_count
  end

  def controversially_excellent?
    return false if single_score?

    excellent_count = scores.count(&.excellent?)

    bad_count = scores.count(&.bad?)

    excellent_count >= minor_count && bad_count >= minor_count
  end

  def unanimously_good?
    scores.all?(&.good?)
  end

  def mostly_good?
    scores.count(&.good?) == mostly_count
  end

  def half_good?
    scores.count(&.good?) == half_count
  end

  def unanimously_average?
    scores.all?(&.average?)
  end

  def mostly_average_or_bad?
    scores.count do |score|
      score.average? || score.bad?
    end >= mostly_count
  end

  def unanimously_bad?
    scores.all?(&.bad?)
  end

  def mostly_bad?
    scores.count(&.bad?) == mostly_count
  end
end
