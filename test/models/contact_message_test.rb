require "test_helper"

class ContactMessageTest < ActiveSupport::TestCase
  test "фікстура звернення валідна" do
    assert contact_messages(:question).valid?
  end

  test "усі поля обов'язкові" do
    message = ContactMessage.new
    assert_not message.valid?
    %i[name email subject body].each { |field| assert message.errors.key?(field), field }
  end

  test "email перевіряється за форматом" do
    message = contact_messages(:question)
    message.email = "not-an-email"
    assert_not message.valid?
  end

  test "текст звернення щонайменше 10 символів" do
    message = contact_messages(:question)
    message.body = "Привіт"
    assert_not message.valid?
  end
end
