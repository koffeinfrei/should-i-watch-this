class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.belongs_to :movie, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :score

      t.timestamps

      t.index [:movie_id, :user_id], unique: true
    end
  end
end
