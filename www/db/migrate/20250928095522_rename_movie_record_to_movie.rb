class RenameMovieRecordToMovie < ActiveRecord::Migration[8.0]
  def change
    rename_table 'movie_records', 'movies'
  end
end
