class RatingsController < ApplicationController
  include ApplicationHelper

  before_action :require_auth, except: :index

  def index
    if current_user
      @ratings = Rating
        .preload(:movie)
        .where(user: current_user)
        .order(updated_at: :desc, id: :desc)
        .to_a
    else
      save_passwordless_redirect_location!(User)
    end
  end

  def create
    rating_params = params.expect(rating: [:movie_id, :score])
    rating = Rating.create!(rating_params.merge(user: current_user))

    flash[:success] = "Nice! Rating added"
    redirect_to movie_url_for(rating.movie)
  end

  def update
    rating = Rating.find(params[:id])

    if rating.user != current_user
      head :forbidden
      return
    end

    rating_params = params.expect(rating: [:score])
    rating.update!(rating_params)

    flash[:success] = "Ok! Rating updated"
    redirect_to movie_url_for(rating.movie)
  end

  def destroy
    rating = Rating.find(params[:id])

    if rating.user != current_user
      head :forbidden
      return
    end

    rating.destroy!

    flash[:success] = "Fair enough. Rating removed"
    redirect_to movie_url_for(rating.movie), status: :see_other
  end
end
