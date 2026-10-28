class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }
  validate :within_stock

  def subtotal = product.price * quantity

  private

    def within_stock
      return unless product && quantity
      errors.add(:base, "«#{product.name}»: доступно лише #{product.stock} шт.") if quantity > product.stock
    end
end
