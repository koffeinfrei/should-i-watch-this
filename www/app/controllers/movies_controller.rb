class MoviesController < ApplicationController
  def show
    title = params["title"]
    year = params["year"]

    if @movie = Movie.get_local(title, year)
      @page_title = "#{@movie.title} (#{@movie.year})"
      @poster_url = @movie.poster_url
    else
      @fetching = true
      @title = title
      @year = year
    end
  end

  def fetch
    title = params["title"]
    year = params["year"]
    Movie.get!(title, year)
    redirect_to movie_path(title, year)
  rescue Movie::Error => e
    flash[:error] = e.message
    redirect_to error_path
  end
end
