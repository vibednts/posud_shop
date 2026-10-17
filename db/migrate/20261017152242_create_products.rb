class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :brand
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.integer :stock
      t.integer :width_cm
      t.string :installation
      t.integer :capacity_sets
      t.string :energy_class
      t.integer :noise_db
      t.integer :programs_count
      t.integer :warranty_months
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
