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

SPINNER_CHARACTERS = %w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

def progress(text)
  while
    0.upto(SPINNER_CHARACTERS.size - 1) do |index|
      STDOUT << "\r"
      STDOUT << "#{SPINNER_CHARACTERS[index]}  #{text}"
      sleep 0.1
    end
  end
end

channels = {
  progress: Channel(Nil).new,
  imdb: Channel(Nil).new,
  tomato: Channel(Nil).new
}

meta_critic_score = nil
imdb_rating = nil
spawn do
  # omdb
  json = Crest.get("http://www.omdbapi.com/?t=captive%20state&apikey=af8f7bfb").body
  omdb = JSON.parse(json)
  imdb_id = omdb["imdbID"]

  # metacritic from omdb
  meta_critic_score = omdb["Metascore"]

  # imdb
  imdb_html = html("https://www.imdb.com/title/#{imdb_id}")
  imdb_rating = css(imdb_html, %{[itemprop="ratingValue"]})

  channels[:imdb].send(nil)
end

tomato_score = nil
tomato_audience = nil
# tomato
spawn do
  tomato_html = html("https://www.rottentomatoes.com/m/captive_state")

  tomato_score = css(tomato_html, ".mop-ratings-wrap__score .mop-ratings-wrap__percentage")
  tomato_audience = css(tomato_html, ".audience-score .mop-ratings-wrap__percentage")

  channels[:tomato].send(nil)
end

progress_text = "Fetching movie 'Captive State'"
done_text = "Movie 'Captive State':"
spawn do
  progress(progress_text)
  channels[:imdb].receive
  channels[:tomato].receive

  channels[:progress].send(nil)
end

channels[:progress].receive

puts <<-DOC
\r   Movie 'Captive State' #{" " * (progress_text.size - done_text.size)}

   # rotten tomatoes

   score:    #{tomato_score}
   audience: #{tomato_audience}

   # imdb

   rating:   #{imdb_rating}

   # metacritic

   score:    #{meta_critic_score}
DOC
