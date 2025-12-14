class AddNormalIndexOnMoviesTitleNormalized < ActiveRecord::Migration[8.1]
  def change
    add_index :movies, :title_normalized, name: 'index_movies_on_title_normalized_direct'
  end
end
