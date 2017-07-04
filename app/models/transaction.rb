class Transaction < ApplicationRecord
  belongs_to :buy_order, class_name: 'Order', foreign_key: :buy_order_id
  belongs_to :sell_order, class_name: 'Order', foreign_key: :sell_order_id, optional: true

  belongs_to :market
  belongs_to :account
end