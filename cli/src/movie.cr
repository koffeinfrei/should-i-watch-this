require "inflector/core_ext"

require "./score"

class Movie
  property title : String | Nil
  property year : String | Nil
  property director : String | Nil
  property actors : String | Nil
  property imdb_id : String | Nil
  property tomato_url : String | Nil
  property poster_url : String | Nil
  property trailer_url : String | Nil

  getter score = {} of Symbol => Score

  def initialize(title = nil, imdb_id = nil)
    @title = title.strip.titleize if title
    @imdb_id = imdb_id if imdb_id
  end

  def identifier
    title || imdb_id
  end

  def self.parse(title_or_imdb_id)
    if title_or_imdb_id =~ /^tt\d+$/
      self.new(imdb_id: title_or_imdb_id)
    else
      self.new(title: title_or_imdb_id)
    end
  end
end
