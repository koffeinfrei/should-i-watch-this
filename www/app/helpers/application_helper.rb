module ApplicationHelper
  include ViteRails::TagHelpers

  def poster_url(movie)
    poster_url = "/posters/100/#{movie.wiki_id}.jpg"
    if File.exist?(Rails.root.join("public#{poster_url}"))
      poster_url
    else
      vite_asset_path("images/default-poster.png")
    end
  end
end
