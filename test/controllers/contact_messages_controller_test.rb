require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  VALID = { name: "Петро", email: "petro@example.com", subject: "Питання",
            body: "Чи є машина Bosch у наявності в Києві?" }.freeze

  test "форма контактів відкривається" do
    get contacts_path
    assert_response :success
    assert_select "form"
  end

  test "для користувача ім'я та email підставляються автоматично" do
    sign_in users(:customer)
    get contacts_path
    assert_select "input[value=?]", "customer@example.com"
  end

  test "звернення зберігається і надсилається лист" do
    assert_difference("ContactMessage.count", 1) do
      assert_emails 1 do
        post contacts_path, params: { contact_message: VALID }
      end
    end
    assert_redirected_to contacts_path
  end

  test "невалідне звернення не зберігається" do
    assert_no_difference("ContactMessage.count") do
      post contacts_path, params: { contact_message: VALID.merge(email: "bad", body: "") }
    end
    assert_response :unprocessable_entity
  end

  test "спам-бот (заповнене приховане поле) ігнорується" do
    assert_no_difference("ContactMessage.count") do
      post contacts_path, params: { contact_message: VALID, website: "http://spam.example" }
    end
    assert_redirected_to contacts_path
  end
end
