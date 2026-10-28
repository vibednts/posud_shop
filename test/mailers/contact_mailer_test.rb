require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "лист про нове звернення йде магазину з адресою для відповіді" do
    message = contact_messages(:question)
    mail = ContactMailer.new_message(message)

    assert_equal [ ContactMailer::SHOP_EMAIL ], mail.to
    assert_equal [ message.email ], mail.reply_to
    assert_equal "Нове звернення: #{message.subject}", mail.subject
    assert_match message.body, mail.text_part.body.to_s
  end
end
