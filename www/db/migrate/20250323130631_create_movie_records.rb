class CreateMovieRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :movie_records do |t|
      t.string :title
      t.string :description
      t.string :wiki_id
      t.string :imdb_id
      t.string :rotten_id
      t.string :metacritic_id
      t.string :omdb_id
      t.date :release_date
      t.json :raw

      t.timestamps
    end

    add_index(:movie_records, :title, using: 'gin', opclass: :gin_trgm_ops)
  end
end
