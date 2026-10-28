require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def build_order(attrs = {})
    users(:customer).orders.new({
      customer_name: "Іван Петренко", phone: "+380501234567", email: "customer@example.com",
      city: "Київ", address: "Відділення №5",
      delivery_method: "nova_poshta", payment_method: "cash_on_delivery"
    }.merge(attrs))
  end

  # --- Вартість доставки ---

  test "доставка Новою поштою коштує 100 грн для замовлень до 20 000 грн" do
    assert_equal 100, Order.delivery_cost_for("nova_poshta", 12_499)
  end

  test "доставка безкоштовна від 20 000 грн" do
    assert_equal 0, Order.delivery_cost_for("nova_poshta", 20_000)
    assert_equal 0, Order.delivery_cost_for("ukrposhta", 25_000)
  end

  test "кур'єр завжди платний" do
    assert_equal 250, Order.delivery_cost_for("courier", 50_000)
  end

  test "самовивіз безкоштовний" do
    assert_equal 0, Order.delivery_cost_for("pickup", 100)
  end

  # --- Валідації ---

  test "місто й адреса обов'язкові, крім самовивозу" do
    order = build_order(city: "", address: "")
    order.valid?
    assert order.errors.key?(:city)
    assert order.errors.key?(:address)

    order.delivery_method = "pickup"
    order.valid?
    assert_not order.errors.key?(:city)
  end

  test "телефон перевіряється за форматом" do
    order = build_order(phone: "abc")
    order.valid?
    assert order.errors.key?(:phone)
  end

  test "невідомий спосіб доставки не приймається" do
    order = build_order(delivery_method: "teleport")
    order.valid?
    assert order.errors.key?(:delivery_method)
  end

  test "замовлення без товарів невалідне" do
    order = build_order(total: 100)
    order.valid?
    assert order.errors.key?(:order_items)
  end

  # --- Оформлення з кошика ---

  test "place! створює замовлення, списує залишок і очищає кошик" do
    cart = carts(:customer_cart)
    order = build_order

    assert_difference("Order.count", 1) { order.place!(cart) }

    assert_equal 1, order.order_items.size
    assert_equal "Bosch SMV25EX00K", order.order_items.first.product_name
    assert_equal 0, order.delivery_cost, "від 20 000 грн доставка безкоштовна"
    assert_equal 21_999, order.total
    assert_equal 4, products(:bosch).reload.stock
    assert cart.reload.empty?
  end

  test "place! рахує доставку, якщо сума менша за поріг" do
    cart = Cart.create!(user: users(:other))
    cart.add_product(products(:beko), 1)
    order = users(:other).orders.new(build_order.attributes.except("id", "user_id"))

    order.place!(cart)
    assert_equal 100, order.delivery_cost
    assert_equal 12_599, order.total
  end

  test "place! відкочує все, якщо товару не вистачає на складі" do
    cart = carts(:customer_cart)
    cart_items(:customer_bosch).update_column(:quantity, 10)

    assert_no_difference([ "Order.count", "OrderItem.count" ]) do
      assert_raises(Order::OutOfStock) { build_order.place!(cart) }
    end
    assert_equal 5, products(:bosch).reload.stock
    assert_not cart.reload.empty?
  end

  # --- Статуси ---

  test "скасування повертає товари на склад" do
    order = orders(:customer_card_order)
    order.change_status!(:cancelled)
    assert order.cancelled?
    assert_equal 6, products(:bosch).reload.stock
  end

  test "скасоване замовлення не можна відновити" do
    order = orders(:customer_card_order)
    order.change_status!(:cancelled)
    assert_raises(ArgumentError) { order.change_status!(:pending) }
  end

  test "невідомий статус викликає помилку" do
    assert_raises(ArgumentError) { orders(:customer_card_order).change_status!(:lost) }
  end

  # --- Оплата ---

  test "оплатити онлайн можна лише нове замовлення з оплатою карткою" do
    assert orders(:customer_card_order).payable?
    assert_not orders(:other_cash_order).payable?
  end

  test "mark_paid! зберігає дані оплати" do
    order = orders(:customer_card_order)
    order.mark_paid!("4242")
    assert order.paid?
    assert_equal "4242", order.card_last4
    assert_not_nil order.paid_at
    assert_match(/\ADEMO-[0-9A-F]{10}\z/, order.payment_reference)
  end

  test "людські назви статусу, доставки й оплати" do
    order = orders(:customer_card_order)
    assert_equal "Очікує обробки", order.status_label
    assert_equal "Нова пошта (відділення)", order.delivery_label
    assert_equal "Банківська картка онлайн", order.payment_label
  end
end
