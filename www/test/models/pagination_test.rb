require "test_helper"

class PaginationTest < ActiveSupport::TestCase
  test ".apply" do
    movies = Movie.order(:title)
    assert_equal ["Don't Worry Darling", "Her", "Here We Go Round the Mulberry Bush", "Pokémon", "The Bear", "The Terminator"], movies.pluck(:title)

    paginated_movies, pagination = Pagination.apply(movies, 1, per: 2)
    assert_equal({ previous: nil, current: 1, next: 2 }, pagination.to_h)
    assert_equal ["Don't Worry Darling", "Her"], paginated_movies.map(&:title)

    paginated_movies, pagination = Pagination.apply(movies, 2, per: 2)
    assert_equal({ previous: 1, current: 2, next: 3 }, pagination.to_h)
    assert_equal ["Here We Go Round the Mulberry Bush", "Pokémon"], paginated_movies.map(&:title)

    paginated_movies, pagination = Pagination.apply(movies, 3, per: 2)
    assert_equal({ previous: 2, current: 3, next: nil }, pagination.to_h)
    assert_equal ["The Bear", "The Terminator"], paginated_movies.map(&:title)

    paginated_movies, pagination = Pagination.apply(movies, 2, per: 4)
    assert_equal({ previous: 1, current: 2, next: nil }, pagination.to_h)
    assert_equal ["The Bear", "The Terminator"], paginated_movies.map(&:title)
  end
end
