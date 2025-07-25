module ApplicationHelper
  include ViteRails::TagHelpers

  def poster_url(movie, kind)
    size = { show: 300, search: 100 }.fetch(kind)
    poster_url = "/posters/#{size}/#{movie.wiki_id}.jpg"
    if File.exist?(Rails.root.join("public#{poster_url}"))
      poster_url
    else
      vite_asset_path("images/default-poster.png")
    end
  end

  def movie_date(movie)
    if movie.series? && movie.release_date
      "#{movie.release_date.year} - #{movie.end_date&.year}"
    elsif movie.release_date
      movie.release_date.year
    else
      "<em>unknown release date</em>".html_safe
    end
  end
end
