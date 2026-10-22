module Admin
  class OrdersController < BaseController
    def index
      @orders = Order.includes(:user).order(created_at: :desc)
      @orders = @orders.where(status: params[:status]) if Order.statuses.key?(params[:status])
    end

    def show
      @order = Order.includes(:order_items).find(params[:id])
    end

    def update
      @order = Order.find(params[:id])
      @order.change_status!(params.require(:order)[:status])
      redirect_to admin_order_path(@order), notice: "Статус оновлено"
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      redirect_to admin_order_path(@order), alert: e.message
    end
  end
end
