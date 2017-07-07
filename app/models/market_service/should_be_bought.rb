require 'array_stats'

module MarketService
  class ShouldBeBought

    def fire!(market, price, ask_bid_stats, percentile_ask_bid)

      return false if already_bought?(market)

      current_price = price
      stored_price = market.price

      #TODO: Take care of 0.0 prices
      growth = ((current_price * 100) / stored_price).round(2) - 100

      Rails.logger.info "Market: #{market.name} --- #{growth}%"

      if growth >= BOTTOM_THRESHOLD_OF_GROWTH && growth <= CEIL_THRESHOLD_OF_GROWTH #growth <= THRESHOLD_OF_GROWTH #growth >= THRESHOLD_OF_GROWTH
        trend = MarketService::Trend.new.fire!(market.name)
        return false unless trend[:info]
        proper_trend = has_proper_trend(trend[:period], trend[:growth], trend[:spread])
        proper_ask_bid = has_proper_ask_bid_prop(market.name, ask_bid_stats, percentile_ask_bid)

        return proper_trend && proper_ask_bid
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
      #growth >= (PERIOD_GROWTH / 60) * period
      growth > 0
    end

    def has_proper_ask_bid_prop(market_name, ask_bid_stats, percentile_ask_bid)
      ask_bid_prop = ask_bid_stats.select { |market| market[:name] == market_name }

      quantity_condition = ask_bid_prop.first[:quantity_prop] >= percentile_ask_bid
      spread_condition = ask_bid_prop.first[:spread] < SPREAD_LIMIT

      quantity_condition && spread_condition
    end
  end
end