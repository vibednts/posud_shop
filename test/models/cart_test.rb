require "test_helper"

class CartTest < ActiveSupport::TestCase
  setup { @cart = carts(:customer_cart) }

  test "додавання нового товару створює позицію" do
    assert_difference("@cart.cart_items.count", 1) do
      item = @cart.add_product(products(:beko), 2)
      assert item.persisted?
      assert_equal 2, item.quantity
    end
  end

  test "повторне додавання збільшує кількість, а не дублює позицію" do
    assert_no_difference("@cart.cart_items.count") do
      @cart.add_product(products(:bosch), 2)
    end
    assert_equal 3, cart_items(:customer_bosch).reload.quantity
  end

  test "не можна додати більше, ніж є на складі" do
    item = @cart.add_product(products(:beko), 3)
    assert_not item.persisted?
    assert_match "доступно лише 2", item.errors.full_messages.to_sentence
  end

  test "загальна кількість і сума кошика" do
    @cart.add_product(products(:beko), 2)
    assert_equal 3, @cart.total_quantity
    assert_equal 21_999 + 2 * 12_499, @cart.total_price
  end

  test "empty? для порожнього кошика" do
    assert_not @cart.empty?
    assert Cart.create!.empty?
  end
end
