class AddIndexOnImdbId < ActiveRecord::Migration[8.0]
  def change
    add_index :movie_records, :imdb_id
  end
end
