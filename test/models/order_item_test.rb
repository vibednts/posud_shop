require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  setup { @item = order_items(:customer_card_order_bosch) }

  test "subtotal = ціна × кількість" do
    @item.quantity = 3
    assert_equal 65_997, @item.subtotal
  end

  test "кількість і ціна мають бути додатними" do
    @item.quantity = 0
    @item.unit_price = 0
    assert_not @item.valid?
    assert @item.errors.key?(:quantity)
    assert @item.errors.key?(:unit_price)
  end
end
