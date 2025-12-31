def self.from_file(file_name)
  Oj.load(
    File.read(Rails.root.join("app/models/quotes", file_name))
  )
end

namespace :quotes do
  desc "Import quotes"
  task import: :environment do
    quotes =
      from_file("afis-100.json") +
      from_file("lifehack-25.json") +
      from_file("should-i-watch-this.json")

    quotes.each do |quote|
      movie, *more_movies = Movie.search_by_title_and_year(quote["movie"], quote["year"])
      if movie
        if more_movies.any?
          puts "[WARNING: many, movie='#{quote['movie']}', year=#{quote['year']}, wiki_id=#{movie.wiki_id}, wiki_ids=#{ more_movies.map(&:wiki_id).join('|')}]"
        end

        quote = Quote.find_or_initialize_by(movie: movie, quote: quote["quote"])
        if quote.persisted?
          print "S"
        else
          quote.save!
          print "."
        end
      else
        puts "[ERROR: none, movie='#{quote['movie']}', year=#{quote['year']}]"
      end
    end
  end
end
