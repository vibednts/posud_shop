require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  CARD = { card_number: "4242 4242 4242 4242", holder: "IVAN PETRENKO", expiry: "12/35", cvv: "123" }.freeze

  setup do
    @order = orders(:customer_card_order)
    sign_in users(:customer)
  end

  test "сторінка оплати відкривається" do
    get new_order_payment_path(@order)
    assert_response :success
    assert_select "h1", "Оплата замовлення №#{@order.id}"
  end

  test "успішна оплата змінює статус на «Оплачено»" do
    post order_payment_path(@order), params: CARD
    assert_redirected_to order_path(@order)
    @order.reload
    assert @order.paid?
    assert_equal "4242", @order.card_last4
  end

  test "відмова банку показує помилку і не змінює статус" do
    post order_payment_path(@order), params: CARD.merge(card_number: "4000000000000002")
    assert_response :unprocessable_entity
    assert_includes response.body, "недостатньо коштів"
    assert @order.reload.pending?
  end

  test "повторно оплатити вже оплачене замовлення не можна" do
    @order.mark_paid!("4242")
    get new_order_payment_path(@order)
    assert_redirected_to order_path(@order)
  end

  test "замовлення з оплатою при отриманні не оплачується карткою" do
    sign_in users(:other)
    get new_order_payment_path(orders(:other_cash_order))
    assert_redirected_to order_path(orders(:other_cash_order))
  end

  test "чуже замовлення оплатити не можна" do
    sign_in users(:other)
    post order_payment_path(@order), params: CARD
    assert_response :not_found
    assert @order.reload.pending?
  end
end
