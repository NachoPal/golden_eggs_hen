module OrderService
  class Retrieve

    def fire!
      Order.where(account_id: 1, order_type: 'LIMIT_SELL')
    end
  end
end