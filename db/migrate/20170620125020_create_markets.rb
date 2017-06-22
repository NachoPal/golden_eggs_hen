class CreateMarkets < ActiveRecord::Migration[5.0]
  def change
    create_table :markets do |t|
      t.string :name
      t.references :primary_currency
      t.references :secondary_currency
      t.decimal :price, scale: 8, precision: 16
      t.timestamps
    end
  end
end
