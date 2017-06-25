module OrderService
  class SetLostLimit

    def fire!(order)
      calculate_willing_lost(order)
    end

    private

    def calculate_willing_lost(order)
      quantity = order.quantity
      price = ((100 - THRESHOLD_TO_SELL) * order.limit_price) / 100

      {rate: price, quantity: quantity}
    end
  end
end