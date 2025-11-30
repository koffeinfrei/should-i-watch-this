class ImdbWatchlistImport < Import
  def handle_row(movie_id, row)
    {
      movie_id: movie_id,
      user_id: @user.id,
      created_at: row["Created"],
      updated_at: row["Modified"]
    }
  end

  def count(movie_ids)
    WatchlistItem.where(user: @user, movie_id: movie_ids).count
  end

  def upsert(attributes)
    WatchlistItem.upsert_all(attributes, unique_by: [:movie_id, :user_id])
  end
end
