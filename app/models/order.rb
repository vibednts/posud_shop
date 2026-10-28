class Order < ApplicationRecord
  class OutOfStock < StandardError; end

  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum :status, { pending: "pending", paid: "paid", shipped: "shipped",
                  completed: "completed", cancelled: "cancelled" }, validate: true
  enum :delivery_method, { nova_poshta: "nova_poshta", ukrposhta: "ukrposhta",
                           courier: "courier", pickup: "pickup" }, validate: true
  enum :payment_method, { cash_on_delivery: "cash_on_delivery", card: "card" }, validate: true

  DELIVERY_LABELS = {
    "nova_poshta" => "Нова пошта (відділення)",
    "ukrposhta"   => "Укрпошта",
    "courier"     => "Кур'єр за адресою",
    "pickup"      => "Самовивіз з магазину"
  }.freeze
  PAYMENT_LABELS = {
    "cash_on_delivery" => "Оплата при отриманні",
    "card"             => "Банківська картка онлайн"
  }.freeze
  STATUS_LABELS = {
    "pending" => "Очікує обробки", "paid" => "Оплачено", "shipped" => "Відправлено",
    "completed" => "Виконано", "cancelled" => "Скасовано"
  }.freeze

  DELIVERY_COSTS = { "nova_poshta" => 100, "ukrposhta" => 70, "courier" => 250, "pickup" => 0 }.freeze
  FREE_DELIVERY_FROM = 20_000

  validates :customer_name, presence: true, length: { maximum: 80 }
  validates :phone, presence: true,
            format: { with: /\A\+?\d[\d\s\-()]{8,17}\z/, message: "має неправильний формат" }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :city, :address, presence: true, unless: :pickup?
  validates :total, numericality: { greater_than: 0 }
  validates :order_items, presence: { message: "не можуть бути порожніми" }

  # Вартість доставки: безкоштовна від 20 000 грн (крім кур'єра)
  def self.delivery_cost_for(method, items_total)
    return 0 if method.to_s != "courier" && items_total >= FREE_DELIVERY_FROM
    DELIVERY_COSTS.fetch(method.to_s, 0)
  end

  def delivery_label = DELIVERY_LABELS[delivery_method]
  def payment_label  = PAYMENT_LABELS[payment_method]
  def status_label   = STATUS_LABELS[status]
  def items_total    = order_items.sum { |i| i.unit_price * i.quantity }


# Зміна статусу з поверненням товарів на склад при скасуванні
def change_status!(new_status)
  new_status = new_status.to_s
  raise ArgumentError, "Невідомий статус" unless Order.statuses.key?(new_status)
  return if new_status == status
  raise ArgumentError, "Скасоване замовлення не можна відновити" if cancelled?

  transaction do
    if new_status == "cancelled"
      order_items.each do |item|
        Product.where(id: item.product_id).update_all([ "stock = stock + ?", item.quantity ])
      end
    end
    update!(status: new_status)
  end
end

  def payable? = card? && pending?

  def mark_paid!(last4)
    update!(status: "paid", paid_at: Time.current, card_last4: last4,
            payment_reference: "DEMO-#{SecureRandom.hex(5).upcase}")
  end

  # Створює замовлення з кошика: перевіряє залишки, списує їх, очищає кошик
  def place!(cart)
    transaction do
      cart.cart_items.includes(:product).each do |ci|
        order_items.build(product: ci.product, product_name: ci.product.name,
                          unit_price: ci.product.price, quantity: ci.quantity)
      end
      self.delivery_cost = Order.delivery_cost_for(delivery_method, items_total)
      self.total = items_total + delivery_cost
      save!

      order_items.each do |item|
        product = Product.lock.find(item.product_id)
        if product.stock < item.quantity
          raise OutOfStock, "«#{product.name}»: на складі лише #{product.stock} шт."
        end
        product.update!(stock: product.stock - item.quantity)
      end
      cart.cart_items.destroy_all
    end
  end
end
