require "spec"

require "../src/recommender"

# TODO "Hmm, there's no rating about this at all..."
# TODO "Not sure. You may fall asleep, or you may be delighted."
SAMPLES = [
  [
    "Star Wars: Episode IV - A New Hope",
    "93%",
    "96%",
    "8.6",
    "90/100",
    "You should definitely watch this, this is really excellent!",
  ],
  [
    "Terminator 2: Judgment Day",
    "93%",
    "94%",
    "8.5",
    "75/100",
    "You should watch this, this is probably excellent!",
  ],
  [
    "The Fault in Our Stars",
    "81%",
    "85%",
    "7.7",
    "69/100",
    "This is definitely worth watching!",
  ],
  [
    "Joker",
    "69%",
    "89%",
    "8.8",
    "59/100",
    "People seem to either love or hate this.",
  ],
  [
    "Lethal Weapon 2",
    "83%",
    "77%",
    "7.2",
    "70/100",
    "Go ahead, you'll most likely enjoy this!",
  ],
  [
    "Fast & Furious 6",
    "70%",
    "84%",
    "7.1",
    "61/100",
    "Go ahead, you'll probably enjoy this!",
  ],
  [
    "Talladega Nights: The Ballad of Ricky Bobby",
    "71%",
    "73%",
    "6.6",
    "66/100",
    "You may enjoy this. It could also be boring though.",
  ],
  [
    "Enemy",
    "71%",
    "63%",
    "6.9",
    "61/100",
    "Meh. This seems to be ok, but it probably won't change your life.",
  ],
  [
    "Grudge Match",
    "31%",
    "46%",
    "6.4",
    "35/100",
    "Please go along. There's nothing to see here.",
  ],
  [
    "Alone in the Dark",
    "1%",
    "11%",
    "2.4",
    "9/100",
    "Be prepared for something awful.",
  ],
  [
    "Terminator 3: Rise of the Machines",
    "69%",
    "46%",
    "6.3",
    "66/100",
    "This seems to be rather something that's not actually good.",
  ],
]

describe Recommender do
  describe "#run" do
    SAMPLES.each do |(title, rating1, rating2, rating3, rating4, expected)|
      it "'#{title}'" do
        score = {
          :"1" => PercentageScore.new(rating1).as(Score),
          :"2" => PercentageScore.new(rating2).as(Score),
          :"3" => DecimalScore.new(rating3).as(Score),
          :"4" => PercentageScore.new(rating4).as(Score),
        }

        result = Recommender.new(score).run

        result.text.should eq expected
      end
    end
  end
end
