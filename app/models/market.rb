class Market < ApplicationRecord
  has_many :transactionns
  belongs_to :primary_currency, class_name: 'Currency', foreign_key: :primary_currency_id
  belongs_to :secondary_currency, class_name: 'Currency', foreign_key: :secondary_currency_id
end
