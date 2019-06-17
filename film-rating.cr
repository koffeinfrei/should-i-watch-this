require "json"

require "crest"
require "myhtml"

def html(url)
  html = Crest.get(url).body

  Myhtml::Parser.new(html)
end

def css(html, expression)
  html.css(expression).first.inner_text.strip
end

# omdb
json = Crest.get("http://www.omdbapi.com/?t=captive%20state&apikey=af8f7bfb").body
imdb_id = JSON.parse(json)["imdbID"]

# imdb
imdb_html = html("https://www.imdb.com/title/#{imdb_id}")

imdb_rating = css(imdb_html, %{[itemprop="ratingValue"]})

# tomato
tomato_html = html("https://www.rottentomatoes.com/m/captive_state")

tomato_score = css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage")
tomato_audience = css(tomato_html, ".audience-score .mop-ratings-wrap__percentage")

puts <<-DOC
# rotten tomatoes

  score:    #{tomato_score}
  audience: #{tomato_audience}

# imdb

  rating:   #{imdb_rating}
DOC
