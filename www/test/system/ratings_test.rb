require "application_system_test_case"

class WatchlistsTest < ApplicationSystemTestCase
  include ApplicationHelper

  fixtures :movies

  test "rate a movie" do
    MovieScore.save("Q788822", {}, nil)
    user = User.create!(email: "user@example.com")
    movie = movies(:her)

    sign_in user

    visit movie_url_for(movie)

    assert_selector "h2", text: "Her"

    # create
    click_on "Rate"
    assert_no_link "Remove my rating"
    click_on "2 points out of 5"
    assert_text "Nice! Rating added"
    assert_text :all, "Your rating:👍2 points out of 5"

    # update
    click_on "Your rating"
    assert_link "Remove my rating"
    click_on "3 points out of 5"
    assert_text "Ok! Rating updated"
    assert_text :all, "Your rating:👍3 points out of 5"

    # remove
    click_on "Your rating"
    click_on "Remove my rating"
    assert_text "Fair enough. Rating removed"
    assert_button "Rate"
  end

  test "import imdb ratings" do
    user = User.create!(email: "user@example.com")
    movie = movies(:her)
    Rating.create! user: user, movie: movie, score: 4

    sign_in user

    click_on "Ratings"

    within ".movie-list-item" do
      assert_text "Her"
    end

    click_on "Import from IMDb"

    attach_file "file", file_fixture("imdb_ratings_export.csv")
    click_on "Import"

    assert_content "Your IMDb ratings were imported:"
    assert_content "New items: 2"
    assert_content "Existing items: 1"
    assert_content "Failed items: 3"

    items = all ".movie-list-item"
    assert_equal 3, items.size
    within items[0] do
      assert_text "Here We Go Round the Mulberry Bush"
    end
    within items[1] do
      assert_text "Her"
    end
    within items[2] do
      assert_text "The Terminator"
    end
  end

  test "requires sign in to rate" do
    MovieScore.save("Q788822", {}, nil)
    movie = movies(:her)
    user = User.create!(email: "user@example.com")

    visit movie_url_for(movie)

    click_on "Rate"
    assert_content "You need to sign in to be able to rate this"
    sign_in user, skip_visit: true
    # TODO: open dialog directly after redirect
    click_on "Rate"
    click_on "2 points out of 5"
    assert_text "Nice! Rating added"
  end

  test "list all ratings" do
    user = User.create!(email: "user@example.com")
    movie1 = movies(:her)
    movie2 = movies(:terminator)
    show = movies(:the_bear)
    Rating.create! user: user, movie: show, score: 5
    Rating.create! user: user, movie: movie1, score: 1
    Rating.create! user: user, movie: movie2, score: 5

    # other user
    other_movie = movies(:here_we_go_round_the_mulberry_bush)
    other_user = User.create!(email: "other_user@example.com")
    Rating.create! user: other_user, movie: other_movie, score: 1

    visit root_path
    click_on "Ratings"
    assert_selector "h2", text: "Your ratings"

    assert_content "You need to sign in to be able to have ratings."
    click_on "sign in"
    sign_in user, skip_visit: true

    assert_selector "h2", text: "Your ratings"

    items = all ".movie-list-item", count: 3
    within items[0] do
      assert_content "Terminator"
      assert_content :all, "5 points out of 5"
    end
    within items[1] do
      assert_content "Her"
      assert_content :all, "1 points out of 5"
    end
    within items[2] do
      assert_content "The Bear"
      assert_content :all, "5 points out of 5"
    end

    assert_no_text "Here We Go Round the Mulberry Bush"

    # change collection filter
    select "Shows", from: "collection"
    assert_no_text "Her"
    items = all ".movie-list-item", count: 1
    within items[0] do
      assert_content "The Bear"
      assert_content :all, "5 points out of 5"
    end

    select "Movies", from: "collection"
    assert_no_text "The Bear"
    items = all ".movie-list-item", count: 2
    within items[0] do
      assert_content "Terminator"
      assert_content :all, "5 points out of 5"
    end
    within items[1] do
      assert_content "Her"
      assert_content :all, "1 points out of 5"
    end
  end
end
