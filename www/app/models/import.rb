require "csv"

class Import
  Result = Data.define(:new, :existing, :failed)

  def initialize(user, io)
    @user = user
    @io = io
  end

  def create
    csv = CSV.new(@io, headers: true)

    imdb_ids = csv.map { _1["Const"] }
    movie_ids = Movie.where(imdb_id: imdb_ids).pluck(:imdb_id, :id).to_h
    csv.rewind

    missing = []

    attributes = csv.map do |row|
      imdb_id = row["Const"]
      movie_id = movie_ids[imdb_id]
      if movie_id
        handle_row(movie_id, row)
      else
        missing << imdb_id
        nil
      end
    end.compact

    existing_count = count(movie_ids.values)
    upsert_result = upsert(attributes)

    Result.new(
      upsert_result.length - existing_count,
      existing_count,
      missing.size
    )
  end
end
