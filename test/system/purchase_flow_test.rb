require "application_system_test_case"

# Повний шлях покупця: каталог → товар → кошик → вхід → оформлення → оплата
class PurchaseFlowTest < ApplicationSystemTestCase
  test "гість додає товар, входить і оформлює замовлення з оплатою при отриманні" do
    visit products_path
    click_on products(:beko).name
    assert_selector "h1", text: products(:beko).name

    click_button "Додати в кошик"
    assert_selector "h1", text: "Кошик"
    assert_text products(:beko).name

    sign_in_via_form("other@example.com")

    visit new_order_path
    assert_selector "h1", text: "Оформлення замовлення"
    fill_in "order[city]", with: "Львів"
    fill_in "order[address]", with: "Відділення №12"
    choose "order_delivery_method_nova_poshta"
    choose "order_payment_method_cash_on_delivery"
    click_button "Підтвердити замовлення"

    order = users(:other).orders.order(:id).last
    assert_selector "h1", text: "Замовлення №#{order.id}"
    assert_text "Дякуємо"
    assert_equal 12_599, order.total
    assert_equal 1, products(:beko).reload.stock
  end

  test "покупець оплачує замовлення карткою" do
    sign_in_via_form("customer@example.com")

    visit new_order_path
    fill_in "order[city]", with: "Київ"
    fill_in "order[address]", with: "Відділення №5"
    choose "order_payment_method_card"
    click_button "Підтвердити замовлення"

    order = users(:customer).orders.order(:id).last
    assert_selector "h1", text: "Оплата замовлення №#{order.id}"

    fill_in "card_number", with: "4242 4242 4242 4242"
    fill_in "holder", with: "IVAN PETRENKO"
    fill_in "expiry", with: "12/35"
    fill_in "cvv", with: "123"
    click_button "Сплатити", exact: false

    assert_text "Оплату прийнято"
    assert order.reload.paid?
  end
end
