class Rating < ApplicationRecord
  SCORES = 1..5

  belongs_to :movie
  belongs_to :user

  validates :score, numericality: { in: SCORES }
end
