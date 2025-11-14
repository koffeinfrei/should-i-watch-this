class WatchlistItemsController < ApplicationController
  include ApplicationHelper

  def toggle
    movie = Movie.find(params[:movie_id])

    if current_user
      item = WatchlistItem.find_or_initialize_by(user: current_user, movie: movie)
      if item.persisted?
        item.destroy!
        flash[:success] = "The movie '#{movie.title}' was removed from your watchlist"
      else
        item.save!
        flash[:success] = "The movie '#{movie.title}' was added to your watchlist"
      end

      redirect_to params[:return_to]
    else
      session[redirect_session_key(User)] = movie_url_for(movie)
      redirect_to users_sign_in_path
    end
  end
end
