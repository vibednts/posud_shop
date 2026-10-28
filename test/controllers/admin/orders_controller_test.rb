require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:admin) }

  test "список усіх замовлень" do
    get admin_orders_path
    assert_response :success
    assert_includes response.body, orders(:customer_card_order).customer_name
    assert_includes response.body, orders(:other_cash_order).customer_name
  end

  test "фільтр замовлень за статусом" do
    orders(:other_cash_order).update_column(:status, "shipped")
    get admin_orders_path(status: "shipped")
    assert_includes response.body, orders(:other_cash_order).customer_name
    assert_not_includes response.body, orders(:customer_card_order).customer_name
  end

  test "сторінка замовлення" do
    get admin_order_path(orders(:customer_card_order))
    assert_response :success
    assert_includes response.body, "Bosch SMV25EX00K"
  end

  test "зміна статусу замовлення" do
    patch admin_order_path(orders(:other_cash_order)), params: { order: { status: "shipped" } }
    assert_redirected_to admin_order_path(orders(:other_cash_order))
    assert orders(:other_cash_order).reload.shipped?
  end

  test "скасування повертає товар на склад" do
    patch admin_order_path(orders(:other_cash_order)), params: { order: { status: "cancelled" } }
    assert_equal 3, products(:beko).reload.stock
  end

  test "невідомий статус показує помилку" do
    patch admin_order_path(orders(:other_cash_order)), params: { order: { status: "lost" } }
    assert_equal "Невідомий статус", flash[:alert]
    assert orders(:other_cash_order).reload.pending?
  end
end
