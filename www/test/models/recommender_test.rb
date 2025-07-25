require "test_helper"

class RecommenderTest < ActiveSupport::TestCase
  # TODO "Hmm, there's no rating about this at all..."
  # TODO "Not sure. You may fall asleep, or you may be delighted."
  SAMPLES = [
    [
      "Star Wars: Episode IV - A New Hope",
      "93%",
      "96%",
      "8.6",
      "90/100",
      "You should definitely watch this, this is really excellent!"
    ],
    [
      "Terminator 2: Judgment Day",
      "93%",
      "94%",
      "8.5",
      "75/100",
      "You should watch this, this is probably excellent!"
    ],
    [
      "The Fault in Our Stars",
      "81%",
      "85%",
      "7.7",
      "69/100",
      "This is definitely worth watching!"
    ],
    [
      "Joker",
      "69%",
      "89%",
      "8.8",
      "59/100",
      "This is definitely worth watching!"
    ],
    [
      "Half Baked",
      "29%",
      "81%",
      "6.7",
      "16/100",
      "People seem to either love or hate this."
    ],
    [
      "Ad Astra",
      "83%",
      "40%",
      "6.5",
      "80/100",
      "People seem to either love or hate this."
    ],
    [
      "Lethal Weapon 2",
      "83%",
      "77%",
      "7.2",
      "70/100",
      "Go ahead, you'll most likely enjoy this!"
    ],
    [
      "Fast & Furious 6",
      "70%",
      "84%",
      "7.1",
      "61/100",
      "Go ahead, you'll probably enjoy this!"
    ],
    [
      "Talladega Nights: The Ballad of Ricky Bobby",
      "71%",
      "73%",
      "6.6",
      "66/100",
      "You may enjoy this. It could also be boring though."
    ],
    [
      "Shot Caller",
      "69%",
      "80%",
      "7.3",
      "59/100",
      "You may enjoy this. It could also be boring though."
    ],
    [
      "The Assistant",
      nil,
      nil,
      "6.1",
      "79/100",
      "You may enjoy this. It could also be boring though."
    ],
    [
      "Love Story",
      "68%",
      "75%",
      "6.9",
      "84/100",
      "You may enjoy this. It could also be boring though."
    ],
    [
      "Enemy",
      "71%",
      "63%",
      "6.9",
      "61/100",
      "Meh. This seems to be ok, but it probably won't change your life."
    ],
    [
      "Wander",
      nil,
      nil,
      "5.0",
      nil,
      "Meh. This seems to be ok, but it probably won't change your life."
    ],
    [
      "Grudge Match",
      "31%",
      "46%",
      "6.4",
      "35/100",
      "Please move along. There's nothing to see here."
    ],
    [
      "Replicas",
      "11%",
      "33%",
      "5.5",
      "19/100",
      "Please move along. There's nothing to see here."
    ],
    [
      "Alone in the Dark",
      "1%",
      "11%",
      "2.4",
      "9/100",
      "Be prepared for something awful."
    ],
    [
      "Breach",
      nil,
      nil,
      "2.7",
      nil,
      "Be prepared for something awful."
    ],
    [
      "Terminator 3: Rise of the Machines",
      "69%",
      "46%",
      "6.3",
      "66/100",
      "This seems to be rather something that's not actually good."
    ]
  ]

  def get_score_instance(value, target_score_class)
    if value
      target_score_class.new(value)
    else
      Score::Missing.new
    end
  end

  SAMPLES.each do |(title, rating1, rating2, rating3, rating4, expected)|
    test "#run (#{title})" do
      score = {
        "1": get_score_instance(rating1, Score::Percentage),
        "2": get_score_instance(rating2, Score::Percentage),
        "3": get_score_instance(rating3, Score::Decimal),
        "4": get_score_instance(rating4, Score::Percentage)
      }

      result = Recommender.new(score).run

      assert_equal expected, result.text
    end
  end
end
