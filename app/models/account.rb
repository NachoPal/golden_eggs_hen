class Account < ApplicationRecord
  has_many :wallets
  has_many :transactions
end
