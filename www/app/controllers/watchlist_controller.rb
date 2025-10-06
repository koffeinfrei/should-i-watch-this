class WatchlistController < ApplicationController
  def show
    if current_user
      @movies = WatchlistItem
        .preload(:movie)
        .where(user: current_user)
        .order(updated_at: :desc, id: :desc)
        .map(&:movie)
    end
  end
end
