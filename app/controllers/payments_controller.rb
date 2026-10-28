class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order
  before_action :ensure_payable

  def new; end

  def create
    result = FakePayment.new(
      number: params[:card_number], holder: params[:holder],
      expiry: params[:expiry], cvv: params[:cvv]
    ).call

    if result.success?
      @order.mark_paid!(result.last4)
      redirect_to order_path(@order), notice: "Оплату прийнято. Дякуємо за замовлення!"
    else
      flash.now[:alert] = result.error
      render :new, status: :unprocessable_entity
    end
  end

  private

    def set_order
      @order = current_user.orders.find(params[:order_id])
    end

    def ensure_payable
      return if @order.payable?

      redirect_to order_path(@order), alert: "Це замовлення не потребує оплати карткою"
    end
end
