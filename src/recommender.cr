require "./score"
require "./recommendation"

class Recommender
  getter scores : Array(Score)
  getter mostly_count : Int32
  getter half_count : Int32

  def initialize(scores)
    @scores = scores.values.reject { |score| score.is_a?(MissingScore) }
    @mostly_count = (@scores.size * 0.75).round.to_i
    @half_count = (@scores.size * 0.5).round.to_i
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def run
    text, emoji =
      if no_rating?
        ["Hmm, there's no rating about this at all...", ":question:"]
      elsif unanimously_excellent?
        ["You should definitely watch this, this is really excellent!", ":star:"]
      elsif mostly_excellent?
        ["You should watch this, this is probably excellent!", ":sparkles:"]
      elsif controversially_excellent?
        ["People seem to either love or hate this.", ":fire:"]
      elsif half_excellent?
        ["This is definitely worth watching!", ":clap:"]
      elsif unanimously_good?
        ["Go ahead, you'll most likely enjoy this!", ":+1:"]
      elsif mostly_good?
        ["Go ahead, you'll probably enjoy this!", ":+1:"]
      elsif half_good?
        ["You may enjoy this. It could also be boring though.", ":ok_hand:"]
      elsif unanimously_average?
        ["Meh. This seems to be ok, but it probably won't change your life.", ":partly_sunny:"]
      elsif mostly_bad?
        ["Please go along. There's nothing to see here.", ":anguished:"]
      elsif unanimously_bad?
        ["Be prepared for something awful.", ":-1:"]
      elsif mostly_average_or_bad?
        ["This seems to be rather something that's not actually good.", ":sleeping:"]
      else
        ["Not sure. You may fall asleep, or you may be delighted.", ":confused:"]
      end

    Recommendation.new(text, emoji)
  end

  # ameba:enable Metrics/CyclomaticComplexity

  def no_rating?
    scores.all?(&.not_defined?)
  end

  # TODO remove all not_defined?
  def unanimously_excellent?
    scores.all? do |score|
      score.excellent? || score.not_defined?
    end
  end

  def mostly_excellent?
    scores.count do |score|
      score.excellent? || score.not_defined?
    end == mostly_count
  end

  def half_excellent?
    scores.count do |score|
      score.excellent? || score.not_defined?
    end == half_count
  end

  def controversially_excellent?
    excellent_count = scores.count do |score|
      score.excellent? || score.not_defined?
    end

    average_or_bad_count = scores.count do |score|
      (score.average? && !score.good?) || score.bad? || score.not_defined?
    end

    excellent_count == half_count && average_or_bad_count >= half_count
  end

  def unanimously_good?
    scores.all? do |score|
      score.good? || score.not_defined?
    end
  end

  def mostly_good?
    scores.count do |score|
      score.good? || score.not_defined?
    end == mostly_count
  end

  def half_good?
    scores.count do |score|
      score.good? || score.not_defined?
    end == half_count
  end

  def unanimously_average?
    scores.all? do |score|
      score.average? || score.not_defined?
    end
  end

  def mostly_average_or_bad?
    scores.count do |score|
      score.average? || score.bad? || score.not_defined?
    end >= mostly_count
  end

  def unanimously_bad?
    scores.all? do |score|
      score.bad? || score.not_defined?
    end
  end

  def mostly_bad?
    scores.count do |score|
      score.bad? || score.not_defined?
    end == mostly_count
  end
end
