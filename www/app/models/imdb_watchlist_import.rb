require "csv"

class ImdbWatchlistImport
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
        {
          movie_id: movie_id,
          user_id: @user.id,
          created_at: row["Created"],
          updated_at: row["Modified"]
        }
      else
        missing << imdb_id
        nil
      end
    end.compact

    existing_count = WatchlistItem.where(user: @user, movie_id: movie_ids.values).count

    result = WatchlistItem.upsert_all(attributes, unique_by: [:movie_id, :user_id])

    Result.new(
      result.length - existing_count,
      existing_count,
      missing.size
    )
  end
end
