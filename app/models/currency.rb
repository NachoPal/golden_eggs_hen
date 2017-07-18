class Currency < ApplicationRecord
  has_many :wallets
  has_one :market, foreign_key: :secondary_currency_id
end
