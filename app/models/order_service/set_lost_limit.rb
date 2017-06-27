module OrderService
  class SetLostLimit

    def fire!(order, set_type)
      calculate_willing_lost(order, set_type)
    end

    private

    def calculate_willing_lost(order, set_type)
      {rate: nil, quantity: nil}
      quantity = order.quantity

      if set_type == 'first'

        price = ((100 - THRESHOLD_TO_SELL) * order.limit_price) / 100

        {rate: price, quantity: quantity}
      elsif set_type == 'reset'
        market_name = order.market.name
        current_price = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first['Last']
        order_price = order.limit_price

        if current_price > (order_price * (100 + (THRESHOLD_TO_SELL) * GAIN_FACTOR)) / 100
          price = current(current_price - order_price) / 2
          {rate: price, quantity: quantity}
        end
      end
    end
  end
end