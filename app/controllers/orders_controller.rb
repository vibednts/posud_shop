class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_items, only: %i[new create]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.includes(:order_items).find(params[:id])
  end

  def new
    @order = current_user.orders.new(
      customer_name: current_user.name, phone: current_user.phone,
      email: current_user.email, delivery_method: "nova_poshta", payment_method: "cash_on_delivery"
    )
  end

  def create
    @order = current_user.orders.new(order_params)
    @order.place!(current_cart)
    redirect_to @order, notice: "Замовлення №#{@order.id} оформлено. Дякуємо!"
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  rescue Order::OutOfStock => e
    redirect_to cart_path, alert: e.message
  end

  private

  def require_items
    redirect_to cart_path, alert: "Кошик порожній" if current_cart.empty?
  end

  def order_params
    params.require(:order).permit(:customer_name, :phone, :email, :city, :address,
                                  :delivery_method, :payment_method, :comment)
  end
end
