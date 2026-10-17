class CartItemsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    qty = params.fetch(:quantity, 1).to_i.clamp(1, 10)
    item = current_cart.add_product(product, qty)

    if item.errors.empty?
      redirect_to cart_path, notice: "Товар додано в кошик"
    else
      redirect_back_or_to products_path, alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    item = current_cart.cart_items.find(params[:id])
    if item.update(quantity: params[:quantity])
      redirect_to cart_path, notice: "Кількість оновлено"
    else
      redirect_to cart_path, alert: item.errors.full_messages.to_sentence
    end
  end

  def destroy
    current_cart.cart_items.find(params[:id]).destroy
    redirect_to cart_path, notice: "Товар видалено з кошика"
  end
end
