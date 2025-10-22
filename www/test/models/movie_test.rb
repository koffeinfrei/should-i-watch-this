require "test_helper"

class MovieTest < ActiveSupport::TestCase
  test ".search_by_title" do
    assert_equal ["Her", "Here We Go Round the Mulberry Bush"], Movie.search_by_title("her", limit: 7).pluck(:title)
    assert_equal ["Pokémon"], Movie.search_by_title("pokemon", limit: 7).pluck(:title)
    assert_equal ["Pokémon"], Movie.search_by_title("ポケットモンスター", limit: 7).pluck(:title)
  end

  test ".search" do
    assert_equal ["Here We Go Round the Mulberry Bush"], Movie.search("here", limit: 7).pluck(:title)
    assert_equal ["Here We Go Round the Mulberry Bush"], Movie.search("tt0063063", limit: 7).pluck(:title)
    assert_equal ["Here We Go Round the Mulberry Bush"], Movie.search("TT0063063", limit: 7).pluck(:title)
    assert_equal ["Here We Go Round the Mulberry Bush"], Movie.search("Q3133990", limit: 7).pluck(:title)
    assert_equal ["Here We Go Round the Mulberry Bush"], Movie.search("q3133990", limit: 7).pluck(:title)

    assert_raises(Movie::ShortQueryError) { Movie.search("a", limit: 7) }
    assert_raises(Movie::ShortQueryError) { Movie.search(" a ", limit: 7) }
    assert_raises(Movie::UnspecificQueryError) { Movie.search("the", limit: 7) }
    assert_raises(Movie::UnspecificQueryError) { Movie.search("the ", limit: 7) }
  end
end
