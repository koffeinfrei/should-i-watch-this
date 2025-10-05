require "test_helper"

class ImdbWatchlistImportTest < ActiveSupport::TestCase
  fixtures :movies

  test "#build" do
    user = User.create!(email: "user@example.com")
    existing_item = WatchlistItem.create!(user: user, movie: movies(:her))
    file = File.new(file_fixture("imdb_watchlist_export.csv"))

    import = ImdbWatchlistImport.new(user, file)
    result = import.build

    assert_equal 1, result.new
    assert_equal 1, result.existing
    assert_equal 1, result.failed

    assert_equal [
      {
        "id" => existing_item.id,
        "user_id" => user.id,
        "movie_id" => movies(:her).id
      },
      {
        "id" => nil,
        "user_id" => user.id,
        "movie_id" => movies(:terminator).id
      }
    ], result.records.map { _1.attributes.slice("id", "user_id", "movie_id") }
  end
end
