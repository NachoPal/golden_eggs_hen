class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.references :buy_order
      t.references :sell_order
      t.decimal :quantity, scale: 8, precision: 16
      t.decimal :benefit, scale: 8, precision: 16
      t.decimal :percentage, scale: 8, precision: 16
      t.timestamps
    end
  end
end
