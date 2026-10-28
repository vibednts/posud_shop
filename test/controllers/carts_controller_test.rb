require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  test "кошик користувача показує його товари" do
    sign_in users(:customer)
    get cart_path
    assert_response :success
    assert_includes response.body, products(:bosch).name
  end

  test "гостьовий кошик переноситься в акаунт після входу" do
    post cart_items_path, params: { product_id: products(:beko).id, quantity: 1 }

    post user_session_path, params: { user: { email: "customer@example.com", password: "password123" } }
    assert_response :redirect

    cart = carts(:customer_cart).reload
    assert_equal [ products(:beko).id, products(:bosch).id ].sort, cart.cart_items.pluck(:product_id).sort
    assert_equal 0, Cart.where(user_id: nil).count, "гостьовий кошик видалено"
  end
end
