class AddTmdbIdToMovies < ActiveRecord::Migration[8.1]
  def change
    add_column :movies, :tmdb_id, :string
  end
end
