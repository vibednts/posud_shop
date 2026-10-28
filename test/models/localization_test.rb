require "test_helper"

# Повідомлення валідації та Devise виводяться українською
class LocalizationTest < ActiveSupport::TestCase
  test "мова за замовчуванням — українська" do
    assert_equal :uk, I18n.default_locale
  end

  test "повідомлення про помилки замовлення українською" do
    order = Order.new(delivery_method: "nova_poshta", payment_method: "card")
    order.valid?
    assert_includes order.errors.full_messages, "Місто не може бути пустим"
    assert_includes order.errors.full_messages, "Телефон не може бути пустим"
  end

  test "повідомлення Devise українською" do
    assert_equal "Ви увійшли в систему.", I18n.t("devise.sessions.signed_in")
  end
end
