require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def new_review(attrs = {})
    Review.new({ user: users(:customer), product: products(:bosch), rating: 5, body: "Чудова машина" }.merge(attrs))
  end

  test "валідний відгук" do
    assert new_review.valid?
  end

  test "оцінка лише від 1 до 5" do
    assert_not new_review(rating: 0).valid?
    assert_not new_review(rating: 6).valid?
  end

  test "текст від 5 до 1000 символів" do
    assert_not new_review(body: "ок").valid?
    assert_not new_review(body: "а" * 1001).valid?
  end

  test "один користувач — один відгук на товар" do
    duplicate = new_review(product: products(:beko))
    assert_not duplicate.valid?
    assert duplicate.errors.key?(:user_id)
  end
end
