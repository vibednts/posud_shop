class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def add_product(product, qty = 1)
    item = cart_items.find_or_initialize_by(product: product)
    item.quantity = item.new_record? ? qty : item.quantity + qty
    item.save
    item
  end

  def total_quantity = cart_items.sum(:quantity)

  def total_price
    cart_items.includes(:product).sum { |i| i.subtotal }
  end

  def empty? = cart_items.none?
end
