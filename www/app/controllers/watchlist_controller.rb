class WatchlistController < ApplicationController
  def show
    if current_user
      @movies = Movie
        .joins(:watchlist_items)
        .where(watchlist_items: { user: current_user })
        .order(watchlist_items: { updated_at: :desc, id: :desc })

      case params[:collection]
      when "movies"
        @movies = @movies.where(series: false)
      when "shows"
        @movies = @movies.where(series: true)
      end

      @movies = @movies.to_a
    else
      save_passwordless_redirect_location!(User)
    end
  end
end
