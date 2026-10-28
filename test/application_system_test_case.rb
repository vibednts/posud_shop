require "test_helper"

# Системні (наскрізні) тести проходять сценарії так, як це робить користувач:
# відкривають сторінки, натискають кнопки, заповнюють форми.
# Драйвер rack_test не потребує встановленого браузера, тому тести
# однаково працюють і локально, і в GitHub Actions.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :rack_test

  def sign_in_via_form(email, password = "password123")
    visit new_user_session_path
    fill_in "user[email]", with: email
    fill_in "user[password]", with: password
    click_button "Увійти"
  end
end
