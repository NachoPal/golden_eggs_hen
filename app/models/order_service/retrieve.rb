module OrderService
  class Retrieve

    def fire!
      Order.where(account_id: 1, order_type: 'LIMIT_SELL', open: true)
    end
  end
end