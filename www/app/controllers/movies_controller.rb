class MoviesController < ApplicationController
  def show
    wiki_id = params["wiki_id"]

    @scores, @trailer_url = MovieScore.get_local(wiki_id)
    if @scores
      @recommendation = Recommender.new(@scores).run
      @movie = Movie.find_by(wiki_id: wiki_id)
      @page_title = "#{@movie.title} (#{@movie.year})"
      @in_watchlist = WatchlistItem.exists?(movie: @movie, user: current_user)
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

    if MovieScore.get(wiki_id)
      redirect_to movie_path(wiki_id, title, year)
    else
      redirect_to not_found_path
    end
  end

  def legacy
    title = params["title"]
    year = params["year"]

    movie, *more_movies = Movie
      .where(title_original: title)
      .where("EXTRACT(YEAR FROM release_date) = ?", year)
      .all
    if more_movies.any?
      Rails.logger.warn("event=legacy_redirect_ambiguous title=#{title} year=#{year}")
    end

    if movie
      redirect_to movie_path_for(movie)
    else
      redirect_to not_found_path
    end
  end
end
