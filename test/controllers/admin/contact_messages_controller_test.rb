require "test_helper"

class Admin::ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:admin) }

  test "список і перегляд звернень" do
    get admin_contact_messages_path
    assert_response :success
    assert_includes response.body, contact_messages(:question).subject

    get admin_contact_message_path(contact_messages(:question))
    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(contact_messages(:question).body)
  end

  test "видалення звернення" do
    assert_difference("ContactMessage.count", -1) do
      delete admin_contact_message_path(contact_messages(:question))
    end
    assert_redirected_to admin_contact_messages_path
  end
end
