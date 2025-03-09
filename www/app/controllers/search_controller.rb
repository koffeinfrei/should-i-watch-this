class SearchController < ApplicationController
  def new
    @query = params[:query]
  end

  def create
    movie = Movie.search!(params[:query])
    redirect_to movie_url(movie["title"], movie["year"])
  rescue Movie::Error => e
    flash[:error] = e.message
    flash[:query] = params[:query]
    redirect_to error_path
  end
end
