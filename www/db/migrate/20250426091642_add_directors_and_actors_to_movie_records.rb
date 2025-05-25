class AddDirectorsAndActorsToMovieRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :movie_records, :directors, :string, array: true
    add_column :movie_records, :actors, :string, array: true
  end
end
