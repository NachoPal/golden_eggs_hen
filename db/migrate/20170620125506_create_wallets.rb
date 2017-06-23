class CreateWallets < ActiveRecord::Migration[5.0]
  def change
    create_table :wallets do |t|
      t.belongs_to :account, index: true
      t.belongs_to :currency, index: true
      t.decimal :balance, scale: 8, precision: 16
      t.decimal :available, scale: 8, precision: 16
      t.decimal :pending, scale: 8, precision: 16
      t.string :address
      t.timestamps
    end
  end
end
