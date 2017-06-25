class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :uuid
      t.belongs_to :account, index: true
      t.belongs_to :market_service, index: true
      t.string :order_type
      t.decimal :quantity, scale: 8, precision: 16
      t.decimal :quantity_remaining, scale: 8, precision: 16
      t.decimal :limit_price, scale: 8, precision: 16
      t.boolean :open
      t.timestamps
    end
  end
end
