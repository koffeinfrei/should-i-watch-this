require "application_system_test_case"

class WatchlistsTest < ApplicationSystemTestCase
  include ApplicationHelper

  fixtures :movies

  test "search for a movie" do
    MovieScore.save("Q788822", {}, nil)

    visit root_path

    # search help
    click_on "Search help"
    within "dialog" do
      assert_text 'Search by title 🠖 "Hero"'
      click_on "Close dialog"
    end

    # search movie
    fill_in "Movie title or IMDb id", with: "Her"

    assert_selector ".movie-list-item", text: "Her"
    items = all ".movie-list-item"
    assert_equal 3, items.size
    within items[0] do
      assert_text "Her"
    end
    within items[1] do
      assert_text "Here We Go Round the Mulberry Bush"
    end
    within items[2] do
      assert_text "Show all results"
    end

    find(".movie-list-item", text: "Her", match: :first).click

    assert_selector "h2", text: "Her"
  end
end
