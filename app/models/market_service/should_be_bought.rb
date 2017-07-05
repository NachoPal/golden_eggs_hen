module MarketService
  class ShouldBeBought

    def fire!(market, price)

      return false if already_bought?(market)

      current_price = price
      stored_price = market.price

      #TODO: Take care of 0.0 prices
      growth = ((current_price * 100) / stored_price).round(2) - 100

      Rails.logger.info "Market: #{market.name} --- #{growth}%"

      if growth >= THRESHOLD_OF_GROWTH #growth <= THRESHOLD_OF_GROWTH #growth >= THRESHOLD_OF_GROWTH
        trend = MarketService::Trend.new.fire!(market.name)
        return false unless trend[:info]
        return has_proper_trend(trend[:period], trend[:growth], trend[:spread])
        #return true
      end

      false
    end

    private

    def already_bought?(market)
      secondary_currency_id = market.secondary_currency_id

      wallet = Wallet.where(currency_id: secondary_currency_id)
      wallet.present?
    end

    def has_proper_trend(period, growth, spread)
      growth > (PERIOD_GROWTH / 60) * period
    end
  end
end