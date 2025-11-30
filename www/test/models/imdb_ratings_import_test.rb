require "test_helper"

class ImdbRatingsImportTest < ActiveSupport::TestCase
  fixtures :movies

  test "#create" do
    user = User.create!(email: "user@example.com")
    existing_item = Rating.create!(user: user, movie: movies(:her), score: 4)
    file = File.new(file_fixture("imdb_ratings_export.csv"))

    import = ImdbRatingsImport.new(user, file)
    result = import.create

    assert_equal 2, result.new
    assert_equal 1, result.existing
    assert_equal 3, result.failed

    assert_equal [
      {
        "id" => existing_item.id,
        "user_id" => user.id,
        "movie_id" => movies(:her).id,
        "score" => 4
      },
      {
        "id" => Rating.second.id,
        "user_id" => user.id,
        "movie_id" => movies(:terminator).id,
        "score" => 5
      },
      {
        "id" => Rating.last.id,
        "user_id" => user.id,
        "movie_id" => movies(:here_we_go_round_the_mulberry_bush).id,
        "score" => 1
      }
    ], Rating.all.map { _1.attributes.slice("id", "user_id", "movie_id", "score") }
  end

  test ".score" do
    assert_equal 1, ImdbRatingsImport.score(1)
    assert_equal 1, ImdbRatingsImport.score(2)
    assert_equal 2, ImdbRatingsImport.score(3)
    assert_equal 2, ImdbRatingsImport.score(4)
    assert_equal 3, ImdbRatingsImport.score(5)
    assert_equal 3, ImdbRatingsImport.score(6)
    assert_equal 4, ImdbRatingsImport.score(7)
    assert_equal 4, ImdbRatingsImport.score(8)
    assert_equal 5, ImdbRatingsImport.score(9)
    assert_equal 5, ImdbRatingsImport.score(10)
  end
end
