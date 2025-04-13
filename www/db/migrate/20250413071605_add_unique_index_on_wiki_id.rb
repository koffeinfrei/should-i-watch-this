class AddUniqueIndexOnWikiId < ActiveRecord::Migration[8.0]
  def change
    add_index :movie_records, :wiki_id, unique: true
  end
end
