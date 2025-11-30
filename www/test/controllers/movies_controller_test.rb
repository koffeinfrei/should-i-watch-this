require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  test "redirect legacy urls" do
    get "/Her/2013"
    assert_redirected_to "/Q788822/Her/2013"
  end

  test "generates and recognizes movie paths" do
    params = { controller: "movies", action: "show", wiki_id: "Q109284181", title: "A Good Person", year: "2023" }
    url = "/Q109284181/A%20Good%20Person/2023"

    assert_generates url, params
    assert_recognizes params, url
  end
end
