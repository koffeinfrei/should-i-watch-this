require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  test "redirect legacy urls" do
    get "/Her/2013"
    assert_redirected_to "/Q788822/Her/2013"
  end
end
