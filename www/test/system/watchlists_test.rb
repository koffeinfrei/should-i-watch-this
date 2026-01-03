require "application_system_test_case"

class WatchlistsTest < ApplicationSystemTestCase
  include ApplicationHelper

  fixtures :movies

  test "add a movie to and remove it from the watchlist" do
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

    visit movie_url_for(movie)

    assert_selector "h2", text: "Her"

    assert_button "﹢watchlist"
    assert_no_button "✓ in watchlist"

    # add to watchlist
    click_on "﹢watchlist"
    assert_text "The movie 'Her' was added to your watchlist"
    assert [[movie.id, user.id]], WatchlistItem.pluck(:movie_id, :user_id)

    assert_no_button "﹢watchlist"
    assert_button "✓ in watchlist"

    # remove from watchlist
    click_on "✓ in watchlist"
    assert_text "The movie 'Her' was removed from your watchlist"
    assert 0, WatchlistItem.count
  end

  test "show watchlist" do
    user = User.create!(email: "user@example.com")
    movie = movies(:her)
    show = movies(:the_bear)
    WatchlistItem.create! user: user, movie: show
    WatchlistItem.create! user: user, movie: movie

    sign_in user

    click_on "Watchlist"

    items = all ".movie-list-item", count: 2
    within items[0] do
      assert_text "Her"
    end
    within items[1] do
      assert_text "The Bear"
    end

    # change collection filter
    select "Shows", from: "collection"
    assert_no_text "Her"
    items = all ".movie-list-item", count: 1
    within items[0] do
      assert_text "The Bear"
    end

    select "Movies", from: "collection"
    assert_no_text "The Bear"
    items = all ".movie-list-item", count: 1
    within items[0] do
      assert_text "Her"
      click_on "Remove from watchlist"
    end

    assert_content "The movie 'Her' was removed from your watchlist"

    items = all ".movie-list-item", count: 1
    within items[0] do
      assert_text "The Bear"
      click_on "Remove from watchlist"
    end

    assert_content "The movie 'The Bear' was removed from your watchlist"
    assert_content "Well. You should definitely add some movies to your watchlist."
  end

  test "import imdb watchlist" do
    user = User.create!(email: "user@example.com")
    movie = movies(:her)
    WatchlistItem.create! user: user, movie: movie

    sign_in user

    click_on "Watchlist"

    within ".movie-list-item" do
      assert_text "Her"
    end

    click_on "Import from IMDb"

    attach_file "file", file_fixture("imdb_watchlist_export.csv")
    click_on "Import"

    assert_content "Your IMDb watchlist was imported:"
    assert_content "New items: 2"
    assert_content "Existing items: 1"
    assert_content "Failed items: 3"

    items = all ".movie-list-item", count: 3
    within items[0] do
      assert_text "Here We Go Round the Mulberry Bush"
    end
    within items[1] do
      assert_text "The Terminator"
    end
    within items[2] do
      assert_text "Her"
    end
  end

  test "requires sign in to add to watchlist" do
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

    visit root_path
    click_on "Watchlist"

    assert_content "You need to sign in to be able to have a watchlist."
    assert_no_link "Import from IMDb"

    within ".header" do
      click_on "Sign in"
    end
    sign_in user, skip_visit: true

    assert_content "Well. You should definitely add some movies to your watchlist."
    assert_link "Import from IMDb"

    # "Add" button
    within ".header" do
      click_on "Sign out"
    end
    assert_content "Signed out successfully"

    visit movie_url_for(movies(:her))
    click_on "﹢watchlist"
    sign_in user, skip_visit: true
    assert_selector "h2", text: "Her"
  end
end
