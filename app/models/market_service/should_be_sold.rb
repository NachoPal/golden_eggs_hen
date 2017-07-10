module MarketService
  class ShouldBeSold

    def fire!(buy_order)
      buy_order_price = buy_order.limit_price

      market_name = buy_order.transactionn.market.name
      market = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first
      market_price = market['Last']

      lose_money = market_price <= ((100 - THRESHOLD_OF_LOST) * buy_order_price) / 100
      #gain_money = market_price >= ((100 + THRESHOLD_OF_GAIN) * buy_order_price) / 100

      #lose_money || gain_money
    end
  end
end