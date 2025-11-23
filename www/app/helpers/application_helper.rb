module ApplicationHelper
  include ViteRails::TagHelpers

  def poster_url(movie, kind, only_path: true)
    size = { show: 300, search: 100 }.fetch(kind)
    poster_path = "/posters/#{size}/#{movie.wiki_id}.jpg"

    unless File.exist?(Rails.root.join("public#{poster_path}"))
      poster_path = vite_asset_path("images/default-poster.png")
    end

    if only_path
      poster_path
    else
      "#{root_url.chomp('/')}#{poster_path}"
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

  def movie_url_for(movie, only_path: true)
    args = [movie.wiki_id, movie.title, movie.year]
    if only_path
      movie_path(*args)
    else
      movie_url(*args)
    end
  end

  def rating_thumb(score, **options)
    ratings = { 1 => "-180", 2 => "-135", 3 => "-90", 4 => "-45", 5 => "0" }

    content_tag("div", **options) do
      content_tag("div", style: "transform: rotate(#{ratings[score]}deg)") do
        "👍"
      end +
      content_tag("div", class: "d-none") do
        "#{score} points out of #{Rating::SCORES.max}"
      end
    end
  end
end
