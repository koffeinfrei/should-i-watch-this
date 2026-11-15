class CreateMovieScores < ActiveRecord::Migration[8.1]
  def change
    create_table :movie_scores do |t|
      t.belongs_to :movie, null: false, foreign_key: true

      t.decimal :imdb_value, precision: 5, scale: 2
      t.decimal :rotten_tomatoes_value, precision: 5, scale: 2
      t.decimal :rotten_tomatoes_audience_value, precision: 5, scale: 2
      t.decimal :metacritic_value, precision: 5, scale: 2

      t.string :trailer_url

      t.timestamps
    end
  end
end
