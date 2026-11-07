require "inflector/core_ext"

require "./score"

class Movie
  property title : String?
  property year : String?
  property director : String?
  property actors : String?
  property imdb_id : String?
  property tomato_url : String?
  property poster_url : String?
  property trailer_url : String?

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
      new(imdb_id: title_or_imdb_id)
    else
      new(title: title_or_imdb_id)
    end
  end
end
