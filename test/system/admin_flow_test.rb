require "application_system_test_case"

# Робочий сценарій адміністратора: вхід → новий товар → обробка замовлення
class AdminFlowTest < ApplicationSystemTestCase
  test "адміністратор додає товар і він з'являється в каталозі" do
    sign_in_via_form("admin@dishshop.ua")
    visit new_admin_product_path

    fill_in "product[name]", with: "Siemens SN63HX42VE"
    fill_in "product[brand]", with: "Siemens"
    fill_in "product[price]", with: "32999"
    fill_in "product[stock]", with: "4"
    fill_in "product[capacity_sets]", with: "14"
    fill_in "product[noise_db]", with: "42"
    fill_in "product[programs_count]", with: "8"
    select categories(:full).name, from: "product[category_id]"
    click_button "Створити товар"

    assert_text "Товар додано"
    visit products_path
    assert_text "Siemens SN63HX42VE"
  end

  test "адміністратор відправляє замовлення" do
    sign_in_via_form("admin@dishshop.ua")
    visit admin_order_path(orders(:other_cash_order))
    select Order::STATUS_LABELS["shipped"], from: "order[status]"
    click_button "Зберегти статус"

    assert_text "Статус оновлено"
    assert orders(:other_cash_order).reload.shipped?
  end
end
