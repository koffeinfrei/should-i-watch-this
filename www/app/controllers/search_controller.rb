class SearchController < ApplicationController
  PER = 10
  MAX_PER = 30

  def new
    @query = params[:query]
    @per = [
      params.fetch(:per, 0).to_i + PER,
      MAX_PER
    ].min
    @show_more = @per < MAX_PER
    @movies = MovieRecord.search(params[:query], limit: @per)
  end

  def autocomplete
    @query = params[:q]
    @movies = MovieRecord.search(@query, limit: 7)

    render layout: false
  end
end
