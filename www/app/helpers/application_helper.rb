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
end
