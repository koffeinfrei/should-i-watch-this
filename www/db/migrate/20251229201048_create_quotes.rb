class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.belongs_to :movie, null: false, foreign_key: true
      t.string :quote

      t.timestamps
    end
  end
end
