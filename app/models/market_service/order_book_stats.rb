module MarketService
  class OrderBookStats

    def fire!(markets)

      markets_stats = markets.map do |market|

        ask_orders = Bittrex.client.get("public/getorderbook?market=#{market['MarketName']}&type=sell")
        bid_orders = Bittrex.client.get("public/getorderbook?market=#{market['MarketName']}&type=buy")

        ask_sum = 0
        bid_sum = 0
        ask_numerator = 0
        bid_numerator = 0

        ask_orders.each do |order|
          ask_sum += order['Quantity']
          ask_numerator += order['Quantity'] * order['Rate']
        end

        bid_orders.each do |order|
          bid_sum += order['Quantity']
          bid_numerator += order['Quantity'] * order['Rate']
        end

        weighted_ask_mean = ask_numerator / ask_sum
        weighted_bid_mean = bid_numerator / bid_sum

        volume_prop = bid_sum.to_f / ask_sum.to_f

        quantity_prop = market['OpenBuyOrders'].to_f / market['OpenSellOrders'].to_f

        spread = ((market['Ask'] - market['Bid']) / market['Ask']) * 100

        #Rails.logger.info "Name: #{market['MarketName']} | Prop: #{volume_prop} | Spread: #{spread}"

        update_market(market['MarketName'], weighted_bid_mean, weighted_ask_mean)

        {name: market['MarketName'],
         volume_prop: volume_prop,
         quantity_prop: quantity_prop,
         spread: spread,
         weighted_bid_mean: weighted_bid_mean,
         weighted_ask_mean: weighted_ask_mean }
      end

      markets_stats.sort_by { |market| market[:volume_prop] }.reverse
    end

    private

    def update_market(market_name, bid_mean, ask_mean)
      market = Market.where(name: market_name).first

      if market.weighted_bid_mean.nil?
        market.update(weighted_bid_mean: bid_mean)
        end

      if market.weighted_ask_mean.nil?
        market.update(weighted_ask_mean: ask_mean)
      end
    end
  end
end