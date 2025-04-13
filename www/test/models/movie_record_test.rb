require "test_helper"

class MovieRecordTest < ActiveSupport::TestCase
  test ".search_by_title" do
    assert_equal ["Her", "Here We Go Round the Mulberry Bush"], MovieRecord.search_by_title("her").pluck(:title)
    assert_equal ["Pokémon"], MovieRecord.search_by_title("pokemon").pluck(:title)
    assert_equal ["Pokémon"], MovieRecord.search_by_title("ポケットモンスター").pluck(:title)
  end

  test ".search" do
    assert_equal ["Here We Go Round the Mulberry Bush"], MovieRecord.search("here").pluck(:title)
    assert_equal ["Here We Go Round the Mulberry Bush"], MovieRecord.search("tt0063063").pluck(:title)
    assert_equal ["Here We Go Round the Mulberry Bush"], MovieRecord.search("TT0063063").pluck(:title)
  end
end
