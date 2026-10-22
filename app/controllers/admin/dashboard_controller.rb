module Admin
  class DashboardController < BaseController
    def index
      @products_count = Product.count
      @orders_count = Order.count
      @pending_count = Order.pending.count
      @messages_count = ContactMessage.count
      @revenue = Order.where.not(status: "cancelled").sum(:total)
      @recent_orders = Order.order(created_at: :desc).limit(5)
      @low_stock = Product.where("stock <= 3").order(:stock).limit(5)
    end
  end
end
