require "inflector/core_ext"

require "./score"

class Movie
  property title : String
  property year : String = ""
  property director : String = ""
  property actors : String = ""
  property imdb_id : String = ""
  property tomato_url : String | Nil
  property poster_url : String | Nil

  getter score = {} of Symbol => Score

  def initialize(title)
    @title = title.strip.titleize
  end
end
