class MoviesController < ApplicationController
  def show
    wiki_id = params["wiki_id"]

    if @scores = MovieScore.get_local(wiki_id)
      @recommendation = Recommender.new(@scores).run
      @movie = MovieRecord.find_by(wiki_id: wiki_id)
      @page_title = "#{@movie.title} (#{@movie.year})"
    else
      @fetching = true
      @wiki_id = wiki_id
      @title = params["title"]
      @year = params["year"]
    end
  end

  def fetch
    wiki_id = params["wiki_id"]
    title = params["title"]
    year = params["year"]

    MovieScore.get!(wiki_id)

    redirect_to movie_path(wiki_id, title, year)
  rescue MovieScore::Error => e
    flash[:error] = e.message

    redirect_to error_path
  end

  def legacy
    title = params["title"]
    year = params["year"]

    movie, *more_movies = MovieRecord
      .where(title_original: title)
      .where("EXTRACT(YEAR FROM release_date) = ?", year)
      .all
    if more_movies.any?
      Rails.logger.warn("event=legacy_redirect_ambiguous title=#{title} year=#{year}")
    end

    redirect_to movie_path(movie.wiki_id, movie.title, movie.year)
  end
end
