require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  setup { @item = cart_items(:customer_bosch) }

  test "кількість має бути цілою і більшою за нуль" do
    @item.quantity = 0
    assert_not @item.valid?
    @item.quantity = 1.5
    assert_not @item.valid?
  end

  test "кількість не може перевищувати залишок" do
    @item.quantity = 6
    assert_not @item.valid?
    @item.quantity = 5
    assert @item.valid?
  end

  test "один товар лише раз у кошику" do
    duplicate = CartItem.new(cart: @item.cart, product: @item.product, quantity: 1)
    assert_not duplicate.valid?
    assert duplicate.errors.key?(:product_id)
  end

  test "subtotal = ціна × кількість" do
    @item.quantity = 2
    assert_equal 43_998, @item.subtotal
  end
end
