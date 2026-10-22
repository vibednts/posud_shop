class AddPaymentFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :paid_at, :datetime
    add_column :orders, :payment_reference, :string
    add_column :orders, :card_last4, :string
  end
end
