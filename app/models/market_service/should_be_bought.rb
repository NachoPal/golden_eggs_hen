require 'array_stats'

module MarketService
  class ShouldBeBought

    def fire!(market_record, price, volume, ask, bid, diff, market)

      return false if already_bought?(market_record)

      current_price = price
      stored_price = market_record.price

      current_volume = volume
      stored_volume = market_record.volume

      current_bid = bid
      stored_bid = market_record.weighted_bid_mean

      current_ask = ask
      stored_ask = market_record.weighted_ask_mean

      #TODO: Take care of 0.0 prices
      return false if current_price.nil? || stored_price.nil?

      price_growth = ((current_price * 100) / stored_price).round(2) - 100
      volume_growth = ((current_volume * 100) / stored_volume).round(2) - 100
      ask_growth = ((current_bid * 100) / stored_bid).round(2) - 100
      bid_growth = ((current_ask * 100) / stored_ask).round(2) - 100
      spread = ((market['Ask'] - market['Bid']) / market['Ask']) * 100
      rise_on_the_day = ((current_price * 100) / market['PrevDay']) - 100

      price_condition = price_growth >= BOTTOM_THRESHOLD_OF_GROWTH && price_growth <= CEIL_THRESHOLD_OF_GROWTH #&& price_growth < bid_growth
      #price_condition = price_growth < ask_growth
      volume_condition = volume_growth >= VOLUME_BOTTOM_THRESHOLD_OF_GROWTH
      spread_condition = spread < SPREAD_LIMIT
      ask_bid_condition = bid_growth > BID_THRESHOLD && ask_growth > ASK_THRESHOLD #&& current_bid > current_price

      Rails.logger.info "Market: #{market_record.name} --- price: #{price_growth}% --- volume: #{volume_growth}% --- spread: #{spread} --- ask: #{ask_growth}% --- bid: #{bid_growth}% -- #{rise_on_the_day}%"

      #if price_condition && volume_condition && spread_condition
      #if price_condition && ask_bid_condition && volume_condition && spread_condition
      #if rise_on_the_day >= GAIN_ON_THE_DAY_THRESHOLD
      if market['DailyIncrease'] > 0 && diff > -10
=begin
        trend = MarketService::Trend.new.fire!(market_record.name)

        return false unless trend[:info]

        proper_trend = has_proper_trend(trend[:growth])

        return proper_trend
=end
        return true
        #if proper_trend
          #ask_bid_stats = MarketService::OrderBookStats.new.fire!([market])
          #proper_ask_bid = has_proper_ask_bid_prop(market_record, market_record.name, ask_bid_stats)
          #return proper_ask_bid
          #percentile_ask_bids = MarketService::PercentileAskBidProp.new.fire!(ask_bid_stats)
        #end
      end
      false
    end

    private

    def already_bought?(market)
      secondary_currency_id = market.secondary_currency_id

      wallet = Wallet.where(currency_id: secondary_currency_id)
      wallet.present?
    end

    def has_proper_trend(growth)
      Rails.logger.info "Growth trend: #{growth}"
      growth > TREND_GROWTH
    end

    def has_proper_ask_bid_prop(market_record, market_name, ask_bid_stats)

      stored_weighted_ask_mean = market_record.weighted_ask_mean
      stored_weighted_bid_mean = market_record.weighted_bid_mean

      ask_bid_prop = ask_bid_stats.select { |market| market[:name] == market_name }

      current_weighted_ask_mean = ask_bid_prop.first[:weighted_ask_mean]
      current_weighted_bid_mean = ask_bid_prop.first[:weighted_bid_mean]

      weighted_ask_mean_growth = ((current_weighted_ask_mean * 100) / stored_weighted_ask_mean).round(2) - 100
      weighted_bid_mean_growth = ((current_weighted_bid_mean * 100) / stored_weighted_bid_mean).round(2) - 100

      Rails.logger.info "Bid growth: #{weighted_bid_mean_growth}"
      Rails.logger.info "Ask growth: #{weighted_ask_mean_growth}"

      #quantity_condition = ask_bid_prop.first[:quantity_prop] >= percentile_ask_bid
      spread_condition = ask_bid_prop.first[:spread] < SPREAD_LIMIT

      #quantity_condition && spread_condition
      #weighted_bid_mean_growth > BID_MEAN_GROWTH && spread_condition #&& quantity_condition
      #spread_condition
    end
  end
end