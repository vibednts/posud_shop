module Admin
  class ContactMessagesController < BaseController
    def index
      @messages = ContactMessage.order(created_at: :desc)
    end

    def show
      @message = ContactMessage.find(params[:id])
    end

    def destroy
      ContactMessage.find(params[:id]).destroy
      redirect_to admin_contact_messages_path, notice: "Звернення видалено"
    end
  end
end
