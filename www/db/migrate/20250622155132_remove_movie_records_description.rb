class RemoveMovieRecordsDescription < ActiveRecord::Migration[8.0]
  def change
    remove_column :movie_records, :description
  end
end
