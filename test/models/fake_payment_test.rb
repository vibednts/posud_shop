require "test_helper"

class FakePaymentTest < ActiveSupport::TestCase
  VALID = { number: "4242 4242 4242 4242", holder: "IVAN PETRENKO", expiry: "12/35", cvv: "123" }.freeze

  def pay(attrs = {})
    FakePayment.new(**VALID.merge(attrs)).call
  end

  test "успішна оплата повертає останні 4 цифри" do
    result = pay
    assert result.success?
    assert_equal "4242", result.last4
  end

  test "номер картки має містити 16 цифр" do
    result = pay(number: "4242")
    assert_not result.success?
    assert_equal "Номер картки має містити 16 цифр", result.error
  end

  test "номер картки перевіряється алгоритмом Луна" do
    assert_equal "Невірний номер картки", pay(number: "4242424242424241").error
  end

  test "ім'я власника лише латиницею" do
    assert_match "латиницею", pay(holder: "Іван Петренко").error
  end

  test "термін дії у форматі ММ/РР" do
    assert_match "ММ/РР", pay(expiry: "13/30").error
  end

  test "прострочена картка відхиляється" do
    assert_equal "Термін дії картки минув", pay(expiry: "01/20").error
  end

  test "CVV з трьох цифр" do
    assert_equal "CVV має містити 3 цифри", pay(cvv: "12").error
  end

  test "тестова картка на 0002 імітує відмову банку" do
    result = pay(number: "4000000000000002")
    assert_not result.success?
    assert_match "недостатньо коштів", result.error
  end
end
