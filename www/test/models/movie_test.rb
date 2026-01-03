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

  test '.search "with actor"' do
    Movie.create!(
      title: "From Paris with Love",
      wiki_id: "Q865346",
      title_normalized: "from paris with love",
      title_original: "From Paris with Love",
      directors: ["Pierre Morel"],
      actors: ["John Travolta", "Jonathan Rhys Meyers", "Kasia Smutniak"],
      tsv_title: "'from':1 'love':4 'paris':2 'with':3"
    )

    assert_equal ["The Terminator"], Movie.search("terminator with schwarzenegger", limit: 7).pluck(:title)
    assert_equal ["The Terminator"], Movie.search("terminator with arnold", limit: 7).pluck(:title)
    assert_equal ["The Terminator"], Movie.search("terminator with arnold schwarzenegger", limit: 7).pluck(:title)
    assert_equal ["From Paris with Love"], Movie.search("from paris with love", limit: 7).pluck(:title)
    assert_equal ["From Paris with Love"], Movie.search("with love", limit: 7).pluck(:title)
    assert_equal ["From Paris with Love"], Movie.search("from paris with love with john", limit: 7).pluck(:title)
    assert_equal ["From Paris with Love"], Movie.search("from paris with love with travolta", limit: 7).pluck(:title)
    assert_equal ["From Paris with Love"], Movie.search("from paris with love with john travolta", limit: 7).pluck(:title)
  end

  test '.search "by director"' do
    Movie.create!(
      title: "By War & By God",
      title_normalized: "by war  by god",
      title_original: "By War & By God",
      directors: ["Kent C. Williamson"],
      actors: [],
      tsv_title: "'by':1,3 'god':4 'war':2"
    )

    assert_equal ["The Terminator"], Movie.search("terminator by james", limit: 7).pluck(:title)
    assert_equal ["The Terminator"], Movie.search("terminator by cameron", limit: 7).pluck(:title)
    assert_equal ["The Terminator"], Movie.search("terminator by james cameron", limit: 7).pluck(:title)
    assert_equal ["By War & By God"], Movie.search("by war & by god", limit: 7).pluck(:title)
    assert_equal ["By War & By God"], Movie.search("by war", limit: 7).pluck(:title)
    assert_equal ["By War & By God"], Movie.search("by war & by god by kent", limit: 7).pluck(:title)
    assert_equal ["By War & By God"], Movie.search("by war & by god by williamson", limit: 7).pluck(:title)
    assert_equal ["By War & By God"], Movie.search("by war & by god by kent c. williamson", limit: 7).pluck(:title)
  end

  test '.search "with actor" and "by director"' do
    assert_equal ["The Terminator"], Movie.search("terminator with schwarzenegger by cameron", limit: 7).pluck(:title)
    assert_equal ["The Terminator"], Movie.search("terminator with arnold by james", limit: 7).pluck(:title)
    assert_equal ["The Terminator"], Movie.search("terminator with arnold schwarzenegger by james cameron", limit: 7).pluck(:title)
  end
end
