module MarketService
  class OrderBookStats

    def fire!(markets)

      markets_stats = markets.map do |market|

        ask_orders = Bittrex.client.get("public/getorderbook?market=#{market['MarketName']}&type=sell")
        bid_orders = Bittrex.client.get("public/getorderbook?market=#{market['MarketName']}&type=buy")

        ask_sum = 0
        bid_sum = 0

        ask_orders.each do |order|
          ask_sum += order['Quantity']
        end

        bid_orders.each do |order|
          bid_sum += order['Quantity']
        end

        volume_prop = bid_sum.to_f / ask_sum.to_f

        quantity_prop = market['OpenBuyOrders'].to_f / market['OpenSellOrders'].to_f

        spread = ((market['Ask'] - market['Bid']) / market['Ask']) * 100

        #Rails.logger.info "Name: #{market['MarketName']} | Prop: #{volume_prop} | Spread: #{spread}"

        {name: market['MarketName'], volume_prop: volume_prop, quantity_prop: quantity_prop, spread: spread }
      end

      markets_stats.sort_by { |market| market[:volume_prop] }.reverse
    end
  end
end