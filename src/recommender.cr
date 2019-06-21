require "./movie"
require "./recommendation"

class Recommender
  getter movie : Movie

  def initialize(@movie)
  end

  def run
    text, emoji =
      if unanimously_good?
        ["Go ahead, you'll probably enjoy this!", ":+1:"]
      elsif unanimously_bad?
        ["Be prepared for something awful.", ":-1:"]
      else
        ["Not sure, you may fall asleep.", ":zzz:"]
      end

    Recommendation.new(text, emoji)
  end

  def unanimously_good?
    movie.score[:imdb].good? &&
      movie.score[:tomato].good? &&
      movie.score[:tomato_audience].good? &&
      movie.score[:meta].good?
  end

  def unanimously_bad?
    movie.score[:imdb].bad? &&
      movie.score[:tomato].bad? &&
      movie.score[:tomato_audience].bad? &&
      movie.score[:meta].bad?
  end
end
