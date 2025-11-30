require "csv"

class ImdbRatingsImport < Import
  def handle_row(movie_id, row)
    {
      movie_id: movie_id,
      user_id: @user.id,
      score: self.class.score(row["Your Rating"]),
      created_at: row["Date Rated"],
      updated_at: row["Date Rated"]
    }
  end

  def count(movie_ids)
    Rating.where(user: @user, movie_id: movie_ids).count
  end

  def upsert(attributes)
    # TODO: should we keep our score instead of overwriting?
    Rating.upsert_all(attributes, unique_by: [:movie_id, :user_id])
  end

  def self.score(imdb_score)
    (imdb_score.to_i / 2.0).round
  end
end
