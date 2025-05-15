class AddTsvColumnsToMovieRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :movie_records, :tsv_title, :tsvector
    add_column :movie_records, :tsv_title_original, :tsvector

    add_index :movie_records, :tsv_title, using: 'gin'
    add_index :movie_records, :tsv_title_original, using: 'gin'
  end
end
