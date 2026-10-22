class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :delivery_method
      t.string :payment_method
      t.string :customer_name
      t.string :phone
      t.string :email
      t.string :city
      t.string :address
      t.text :comment
      t.decimal :delivery_cost, precision: 10, scale: 2
      t.decimal :total, precision: 10, scale: 2

      t.timestamps
    end
  end
end
