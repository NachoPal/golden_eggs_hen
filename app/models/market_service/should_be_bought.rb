module MarketService
  class ShouldBeBought

    def fire!(market)

      return if already_bought?(market)

      current_price = Rails.cache.fetch("markets/#{market.id}")
      stored_price = market.price

      #TODO: Take care of 0.0 prices
      growth = ((current_price * 100) / stored_price).round(2) - 100

      Rails.logger.info "#{current_price} - #{stored_price}"
      Rails.logger.info "#{args[:market_record].name} ---- #{growth}%"

      growth >= THRESHOLD_TO_BUY && !Order.where(market_id: market.id).present?
    end

    private

    def already_bought?(market)
      existing_orders = Order.joins([:market_service, :account]).
                              where(markets: {name: market}, accounts: {id: 1})

      existing_orders.present?
    end
  end
end