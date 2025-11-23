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
end
