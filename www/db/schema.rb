# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_23_130631) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "movie_records", force: :cascade do |t|
    t.string "title"
    t.string "wiki_id"
    t.string "imdb_id"
    t.string "rotten_id"
    t.string "metacritic_id"
    t.date "release_date"
    t.json "raw"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "omdb_id"
    t.index ["title"], name: "index_movie_records_on_title", opclass: :gin_trgm_ops, using: :gin
  end
end
