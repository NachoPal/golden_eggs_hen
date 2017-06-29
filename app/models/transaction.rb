class Transaction < ApplicationRecord
  belongs_to :buy_order, class_name: 'Order', foreign_key: :buy_order_id
  belongs_to :sell_order, class_name: 'Order', foreign_key: :sell_order_id, optional: true

  has_one :market, :through => :buy_order, foreign_key: :market_id
  has_one :account, :through => :buy_order, foreign_key: :account_id
end