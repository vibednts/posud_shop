require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  ORDER_PARAMS = {
    customer_name: "Іван Петренко", phone: "+380501234567", email: "customer@example.com",
    city: "Київ", address: "Відділення №5", delivery_method: "nova_poshta",
    payment_method: "cash_on_delivery"
  }.freeze

  test "без входу оформити замовлення не можна" do
    get new_order_path
    assert_redirected_to new_user_session_path
  end

  test "з порожнім кошиком повертає в кошик" do
    sign_in users(:other)
    get new_order_path
    assert_redirected_to cart_path
    assert_equal "Кошик порожній", flash[:alert]
  end

  test "форма оформлення заповнена даними користувача" do
    sign_in users(:customer)
    get new_order_path
    assert_response :success
    assert_select "input[name='order[customer_name]'][value=?]", "Іван Петренко"
    assert_select "input[name='order[email]'][value=?]", "customer@example.com"
  end

  test "оформлення з оплатою при отриманні" do
    sign_in users(:customer)
    assert_difference("Order.count", 1) do
      post orders_path, params: { order: ORDER_PARAMS }
    end
    order = Order.last
    assert_redirected_to order_path(order)
    assert_equal 21_999, order.total
    assert_equal 4, products(:bosch).reload.stock
    assert carts(:customer_cart).reload.empty?
  end

  test "оформлення з оплатою карткою веде на сторінку оплати" do
    sign_in users(:customer)
    post orders_path, params: { order: ORDER_PARAMS.merge(payment_method: "card") }
    assert_redirected_to new_order_payment_path(Order.last)
  end

  test "помилки у формі показуються без створення замовлення" do
    sign_in users(:customer)
    assert_no_difference("Order.count") do
      post orders_path, params: { order: ORDER_PARAMS.merge(phone: "", city: "") }
    end
    assert_response :unprocessable_entity
    assert_equal 5, products(:bosch).reload.stock
  end

  test "якщо товар закінчився, повертає в кошик з поясненням" do
    sign_in users(:customer)
    products(:bosch).update_column(:stock, 0)
    post orders_path, params: { order: ORDER_PARAMS }
    assert_redirected_to cart_path
    assert_match "на складі лише 0", flash[:alert]
  end

  test "історія показує лише власні замовлення" do
    sign_in users(:customer)
    get orders_path
    assert_response :success
    assert_includes response.body, "№#{orders(:customer_card_order).id}"
    assert_not_includes response.body, "№#{orders(:other_cash_order).id}"
  end

  test "чуже замовлення відкрити не можна" do
    sign_in users(:customer)
    get order_path(orders(:other_cash_order))
    assert_response :not_found
  end
end
