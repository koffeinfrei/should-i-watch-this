ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "passwordless/test_helpers"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    def sign_in(user, skip_visit: false)
      visit users_sign_in_path unless skip_visit

      # submit email
      fill_in "E-mail address", with: "user@example.com"
      click_on "Sign in"
      assert_text "We've sent you an email with a secret token"

      # submit token
      token = ActionMailer::Base.deliveries.last.body.to_s.match(/sign in: ([^\n]+)\n/)[1]
      fill_in "Token", with: token
      click_on "Confirm"

      # TODO: show an avatar or the email or something better
      assert_selector ".signed-in"
    end
  end
end
