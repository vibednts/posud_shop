class ContactMessagesController < ApplicationController
  def new
    @contact_message = ContactMessage.new
    if user_signed_in?
      @contact_message.name = current_user.name
      @contact_message.email = current_user.email
    end
  end

  def create
    return redirect_to(contacts_path, notice: "Дякуємо! Ми зв'яжемося з вами.") if params[:website].present?

    @contact_message = ContactMessage.new(contact_params)

    if @contact_message.save
      begin
        ContactMailer.new_message(@contact_message).deliver_now
      rescue StandardError => e
        Rails.logger.error("Contact mail failed: #{e.message}")
      end
      redirect_to contacts_path, notice: "Дякуємо! Ми отримали ваше звернення й зв'яжемося з вами."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_message).permit(:name, :email, :subject, :body)
  end
end
