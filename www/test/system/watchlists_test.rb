require "application_system_test_case"

class WatchlistsTest < ApplicationSystemTestCase
  include ApplicationHelper

  fixtures :movies

  test "signed in: add a movie to and remove it from the watchlist" do
    MovieScore.save(
      "Q788822",
      {
        rotten_tomatoes: Score::Percentage.new("95"),
        rotten_tomatoes_audience: Score::Percentage.new("82"),
        imdb: Score::Decimal.new("8.0"),
        metacritic: Score::Percentage.new("91.0")
      },
      nil
    )
    user = User.create!(email: "user@example.com")
    movie = movies(:her)

    sign_in user

    visit movie_path_for(movie)

    assert_selector "h2", text: "Her"

    assert_button "﹢watchlist"
    assert_no_button "🗸 in watchlist"

    # add to watchlist
    click_on "﹢watchlist"
    assert_text "The movie 'Her' was added to your watchlist"
    assert [[movie.id, user.id]], WatchlistItem.pluck(:movie_id, :user_id)

    assert_no_button "﹢watchlist"
    assert_button "🗸 in watchlist"

    # remove from watchlist
    click_on "🗸 in watchlist"
    assert_text "The movie 'Her' was removed from your watchlist"
    assert 0, WatchlistItem.count
  end

  test "show watchlist" do
    user = User.create!(email: "user@example.com")
    movie = movies(:her)
    WatchlistItem.create! user: user, movie: movie

    sign_in user

    click_on "Watchlist"

    within ".movie-list-item" do
      assert_text "Her"

      click_on "Remove from watchlist"
    end

    assert_content "The movie 'Her' was removed from your watchlist"
    assert_content "Well. You should definitely add some movies to your watchlist."
  end
end
