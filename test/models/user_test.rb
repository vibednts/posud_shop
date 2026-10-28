require "test_helper"

class UserTest < ActiveSupport::TestCase
  def new_user(attrs = {})
    User.new({ email: "new@example.com", name: "Новий", password: "password123" }.merge(attrs))
  end

  test "валідний користувач" do
    assert new_user.valid?
  end

  test "ім'я обов'язкове" do
    assert_not new_user(name: "").valid?
  end

  test "телефон необов'язковий, але перевіряється за форматом" do
    assert new_user(phone: "").valid?
    assert new_user(phone: "+380 (50) 123-45-67").valid?
    assert_not new_user(phone: "телефон").valid?
  end

  test "email має бути унікальним" do
    assert_not new_user(email: users(:customer).email).valid?
  end

  test "пароль щонайменше 6 символів" do
    assert_not new_user(password: "123").valid?
  end

  test "новий користувач не адміністратор" do
    assert_not new_user.admin?
  end
end
