class Quote < ApplicationRecord
  belongs_to :movie

  validates :quote, presence: true

  def self.random
    order("random()").first
  end
end
