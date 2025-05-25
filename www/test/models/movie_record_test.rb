require "test_helper"

class MovieRecordTest < ActiveSupport::TestCase
  test ".search_by_title" do
    assert_equal ["Her", "Here We Go Round the Mulberry Bush"], MovieRecord.search_by_title("her", limit: 7).pluck(:title)
    assert_equal ["Pokémon"], MovieRecord.search_by_title("pokemon", limit: 7).pluck(:title)
    assert_equal ["Pokémon"], MovieRecord.search_by_title("ポケットモンスター", limit: 7).pluck(:title)
  end

  test ".search" do
    assert_equal ["Here We Go Round the Mulberry Bush"], MovieRecord.search("here", limit: 7).pluck(:title)
    assert_equal ["Here We Go Round the Mulberry Bush"], MovieRecord.search("tt0063063", limit: 7).pluck(:title)
    assert_equal ["Here We Go Round the Mulberry Bush"], MovieRecord.search("TT0063063", limit: 7).pluck(:title)
  end
end
