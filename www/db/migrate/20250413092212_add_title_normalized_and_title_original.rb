class AddTitleNormalizedAndTitleOriginal < ActiveRecord::Migration[8.0]
  def change
    add_column :movie_records, :title_normalized, :string
    add_column :movie_records, :title_original, :string

    remove_index(:movie_records, :title)
    add_index(:movie_records, :title_normalized, using: 'gin', opclass: :gin_trgm_ops)
    add_index(:movie_records, :title_original, using: 'gin', opclass: :gin_trgm_ops)
  end
end
