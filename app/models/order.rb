class Order < ApplicationRecord
  belongs_to :account
  belongs_to :market
end
