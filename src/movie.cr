class Movie
  property title : String
  property imdb_id : String = ""
  property year : String = ""
  property director : String = ""
  property actors : String = ""
  property type : String = ""

  getter score = {} of Symbol => Score

  def initialize(title)
    @title = title.strip.titleize
  end
end
