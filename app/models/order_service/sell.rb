module OrderService
  class Sell
    def fire!(market_id, rate, quantity)

      #============ LIVE ==============
      # Bittrex.client.get("market/selllimit?market=#{order.market.name}&
      #                   quantity=#{quantity}&rate=#{rate}")

      #TODO: Select proper account
      Rails.logger.info "============= ENTRA EN CREATE ==============="
      Order.create(account_id: 1, market_id: market_id,
                   order_type: 'LIMIT_SELL', limit_price: rate,
                   quantity: quantity, open: true,
                   quantity_remaining: BigDecimal.new(0))
    end
  end
end