require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  test "гість може додати товар у кошик" do
    assert_difference("Cart.count", 1) do
      post cart_items_path, params: { product_id: products(:beko).id, quantity: 2 }
    end
    assert_redirected_to cart_path
    follow_redirect!
    assert_select "h1", "Кошик"
    assert_includes response.body, products(:beko).name
  end

  test "товар без залишку не додається" do
    post cart_items_path, params: { product_id: products(:sold_out).id },
                          headers: { "HTTP_REFERER" => product_url(products(:sold_out)) }
    assert_redirected_to product_url(products(:sold_out))
    assert_match "доступно лише 0", flash[:alert]
  end

  test "кількість обмежується від 1 до 10 за раз" do
    sign_in users(:customer)
    post cart_items_path, params: { product_id: products(:bosch).id, quantity: -5 }
    assert_equal 2, cart_items(:customer_bosch).reload.quantity
  end

  test "користувач змінює кількість у кошику" do
    sign_in users(:customer)
    patch cart_item_path(cart_items(:customer_bosch)), params: { quantity: 3 }
    assert_redirected_to cart_path
    assert_equal 3, cart_items(:customer_bosch).reload.quantity
  end

  test "кількість більша за залишок не зберігається" do
    sign_in users(:customer)
    patch cart_item_path(cart_items(:customer_bosch)), params: { quantity: 99 }
    assert_match "доступно лише 5", flash[:alert]
    assert_equal 1, cart_items(:customer_bosch).reload.quantity
  end

  test "користувач видаляє товар з кошика" do
    sign_in users(:customer)
    assert_difference("CartItem.count", -1) do
      delete cart_item_path(cart_items(:customer_bosch))
    end
    assert_redirected_to cart_path
  end

  test "чужу позицію кошика змінити не можна" do
    sign_in users(:other)
    patch cart_item_path(cart_items(:customer_bosch)), params: { quantity: 3 }
    assert_response :not_found
    assert_equal 1, cart_items(:customer_bosch).reload.quantity
  end
end
