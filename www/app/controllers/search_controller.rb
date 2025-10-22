class SearchController < ApplicationController
  rescue_from Movie::ShortQueryError do
    @error = :short_query
    render layout: false
  end

  rescue_from ActiveRecord::QueryCanceled, Movie::UnspecificQueryError do
    @error = :unspecific
    render layout: false
  end

  PER = 10
  MAX_PER = 30

  def new
    @per = [
      params.fetch(:per, 0).to_i + PER,
      MAX_PER
    ].min
    @movies = Movie.search(query, limit: @per + 1)
    @show_more = @per < MAX_PER && @movies.size > @per
    @movies = @movies[0, @per]
  end

  def autocomplete
    @movies = Movie.search(query, limit: 7)
    render layout: false
  end

  private

  def query
    params[:query]
  end
  helper_method :query
end
