class SearchController < ApplicationController
  def new
    @query = params[:query]
  end

  def create
    movie = MovieRecord.search(params[:query], limit: 1).first

    redirect_to movie_url(movie.wiki_id, movie.title, movie.year)
  rescue MovieScore::Error => e
    flash[:error] = e.message
    flash[:query] = params[:query]

    redirect_to error_path
  end

  def autocomplete
    @query = params[:q]
    @movies = MovieRecord.search(@query, limit: 7)

    render layout: false
  end
end
