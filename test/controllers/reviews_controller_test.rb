require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  test "гість не може залишити відгук" do
    assert_no_difference("Review.count") do
      post product_reviews_path(products(:bosch)), params: { review: { rating: 5, body: "Супер машина" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "користувач залишає відгук" do
    sign_in users(:customer)
    assert_difference("Review.count", 1) do
      post product_reviews_path(products(:bosch)), params: { review: { rating: 5, body: "Супер машина" } }
    end
    assert_redirected_to product_path(products(:bosch), anchor: "reviews")
    assert_equal "Дякуємо за відгук!", flash[:notice]
  end

  test "другий відгук на той самий товар не зберігається" do
    sign_in users(:customer)
    assert_no_difference("Review.count") do
      post product_reviews_path(products(:beko)), params: { review: { rating: 3, body: "Ще один відгук" } }
    end
    assert_match "вже залишив відгук", flash[:alert]
  end

  test "автор видаляє свій відгук" do
    sign_in users(:customer)
    assert_difference("Review.count", -1) do
      delete product_review_path(products(:beko), reviews(:customer_on_beko))
    end
  end

  test "чужий відгук видалити не можна" do
    sign_in users(:customer)
    assert_no_difference("Review.count") do
      delete product_review_path(products(:beko), reviews(:other_on_beko))
    end
    assert_response :not_found
  end

  test "адміністратор може видалити будь-який відгук" do
    sign_in users(:admin)
    assert_difference("Review.count", -1) do
      delete product_review_path(products(:beko), reviews(:other_on_beko))
    end
  end
end
