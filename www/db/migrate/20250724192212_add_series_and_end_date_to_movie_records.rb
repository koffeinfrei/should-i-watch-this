class AddSeriesAndEndDateToMovieRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :movie_records, :series, :boolean
    add_column :movie_records, :end_date, :date
  end
end
