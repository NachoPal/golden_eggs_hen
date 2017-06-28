module MarketService
  class ShouldBeBought

    def fire!(market, price)

      return false if already_bought?(market)

      current_price = price #Rails.cache.fetch("#{market.id}/markets")
      stored_price = market.price

      #TODO: Take care of 0.0 prices
      growth = ((current_price * 100) / stored_price).round(2) - 100

      Rails.logger.info "#{growth}%"

      growth >= THRESHOLD_TO_BUY #&& !Order.where(market_id: market.id).present?
    end

    private

    def already_bought?(market)
      #TODO: Select proper account
      existing_orders = Order.joins([:market, :account]).
                              where(markets: {name: market.name},
                                    accounts: {id: 1},
                                    order_type: 'LIMIT_SELL',
                                    open: true)

      existing_orders.present?
    end
  end
end