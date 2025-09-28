require "application_system_test_case"

class SignInTest < ApplicationSystemTestCase
  include ApplicationHelper

  test "sign in" do
    user = User.create!(email: "user@example.com")

    sign_in user

    # consecutive sign in redirects
    visit users_sign_in_path

    assert_no_field "E-mail address"
  end
end
