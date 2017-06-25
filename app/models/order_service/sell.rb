module OrderService
  class Sell
    def fire!(order, rate, quantity)

      #============ LIVE ==============
      # Bittrex.client.get("market/selllimit?market=#{order.market.name}&
      #                   quantity=#{quantity}&rate=#{rate}")

      #TODO: Select proper account
      Order.create(account_id: 1, market_id: order.market.id,
                   order_type: 'LIMIT_SELL', limit_price: rate,
                   quantity: quantity,
                   quantity_remaining: BigDecimal.new(0))
    end
  end
end