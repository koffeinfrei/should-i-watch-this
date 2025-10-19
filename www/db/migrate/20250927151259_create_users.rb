class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.timestamps

      t.index 'LOWER(email)', unique: true
    end
  end
end
