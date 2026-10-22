class ContactMailer < ApplicationMailer
  SHOP_EMAIL = "info@dishshop.ua".freeze

  def new_message(contact_message)
    @message = contact_message
    mail(
      to: SHOP_EMAIL,
      reply_to: @message.email,
      subject: "Нове звернення: #{@message.subject}"
    )
  end
end
