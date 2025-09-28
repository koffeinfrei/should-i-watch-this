class SearchController < ApplicationController
  PER = 10
  MAX_PER = 30

  def new
    @query = params[:query]
    @per = [
      params.fetch(:per, 0).to_i + PER,
      MAX_PER
    ].min
    @movies = Movie.search(params[:query], limit: @per + 1)
    @show_more = @per < MAX_PER && @movies.size > @per
    @movies = @movies[0, @per]
  end

  def autocomplete
    @query = params[:q]
    @movies = Movie.search(@query, limit: 7)

    render layout: false
  end
end
