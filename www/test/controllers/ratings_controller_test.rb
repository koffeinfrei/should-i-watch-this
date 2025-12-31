require "test_helper"

class RatingsControllerTest < ActionDispatch::IntegrationTest
  fixtures :movies
  fixtures :quotes

  test "returns 403 when trying to update another user's rating" do
    user1 = User.create!(email: "user1@example.com")
    user2 = User.create!(email: "user2@example.com")
    movie = movies(:her)
    rating = Rating.create!(user: user1, movie: movie, score: 1)

    passwordless_sign_in(user2)
    patch rating_url(rating)
    assert_response :forbidden
  end

  test "returns 403 when trying to update unauthenticated" do
    user = User.create!(email: "user1@example.com")
    movie = movies(:her)
    rating = Rating.create!(user: user, movie: movie, score: 1)

    patch rating_url(rating)
    assert_response :forbidden
  end

  test "returns 403 when trying to destroy another user's rating" do
    user1 = User.create!(email: "user1@example.com")
    user2 = User.create!(email: "user2@example.com")
    movie = movies(:her)
    rating = Rating.create!(user: user1, movie: movie, score: 1)

    passwordless_sign_in(user2)
    delete rating_url(rating)
    assert_response :forbidden
  end

  test "returns 403 when trying to destroy unauthenticated" do
    user = User.create!(email: "user1@example.com")
    movie = movies(:her)
    rating = Rating.create!(user: user, movie: movie, score: 1)

    delete rating_url(rating)
    assert_response :forbidden
  end
end
