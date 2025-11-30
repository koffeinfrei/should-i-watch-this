require "test_helper"

class ImdbWatchlistImportTest < ActiveSupport::TestCase
  fixtures :movies

  test "#create" do
    user = User.create!(email: "user@example.com")
    existing_item = WatchlistItem.create!(user: user, movie: movies(:her))
    file = File.new(file_fixture("imdb_watchlist_export.csv"))

    import = ImdbWatchlistImport.new(user, file)
    result = import.create

    assert_equal 2, result.new
    assert_equal 1, result.existing
    assert_equal 3, result.failed

    assert_equal [
      {
        "id" => existing_item.id,
        "user_id" => user.id,
        "movie_id" => movies(:her).id
      },
      {
        "id" => WatchlistItem.second.id,
        "user_id" => user.id,
        "movie_id" => movies(:terminator).id
      },
      {
        "id" => WatchlistItem.last.id,
        "user_id" => user.id,
        "movie_id" => movies(:here_we_go_round_the_mulberry_bush).id
      }
    ], WatchlistItem.all.map { _1.attributes.slice("id", "user_id", "movie_id") }
  end
end
