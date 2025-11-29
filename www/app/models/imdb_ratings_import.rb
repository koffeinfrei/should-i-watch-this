require "csv"

class ImdbRatingsImport
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
          score: self.class.score(row["Your Rating"]),
          created_at: row["Date Rated"],
          updated_at: row["Date Rated"]
        }
      else
        missing << imdb_id
        nil
      end
    end.compact

    existing_count = Rating.where(user: @user, movie_id: movie_ids.values).count

    # TODO: should we keep our score instead of overwriting?
    result = Rating.upsert_all(attributes, unique_by: [:movie_id, :user_id])

    Result.new(
      result.length - existing_count,
      existing_count,
      missing.size
    )
  end

  def self.score(imdb_score)
    (imdb_score.to_i / 2.0).round
  end
end
