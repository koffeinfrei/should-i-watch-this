class WatchlistItemsController < ApplicationController
  def toggle
    if current_user
      movie = Movie.find(params[:movie_id])
      item = WatchlistItem.find_or_initialize_by(user: current_user, movie: movie)
      if item.persisted?
        item.destroy!
        flash[:success] = "The movie '#{movie.title}' was removed from your watchlist"
      else
        item.save!
        flash[:success] = "The movie '#{movie.title}' was added to your watchlist"
      end

      redirect_to params[:return_to]
    end
  end
end
