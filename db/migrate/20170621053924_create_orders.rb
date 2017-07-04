class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orderrs do |t|
      t.belongs_to :transactionn, index: true
      t.string :type
      t.string :uuid
      t.decimal :quantity, scale: 8, precision: 16
      t.decimal :quantity_remaining, scale: 8, precision: 16
      t.decimal :limit_price, scale: 8, precision: 16
      t.boolean :open
      t.timestamps
    end
  end
end
