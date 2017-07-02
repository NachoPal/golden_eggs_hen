module MarketService
  class ShouldBeSold

    def fire!(wallet, currency_exchange)

      buy_order = find_buy_order_for_wallet(wallet, currency_exchange)
      buy_order_price = buy_order.limit_price

      market_name = buy_order.market.name
      market = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first
      market_price = market['Last']

      lose_money = market_price <= ((100 - THRESHOLD_OF_LOST) * buy_order_price) / 100
      gain_money = market_price >= ((100 + THRESHOLD_OF_GAIN) * buy_order_price) / 100

      lose_money || gain_money
    end

    private

    def find_buy_order_for_wallet(wallet, currency_exchange)
      currency = wallet.currency.name
      market_name = "#{currency_exchange}-#{currency}"
      market = Market.where(name: market_name).first

      #Rails.logger.info "#{market_name}"
      #TODO: Proper Account
      Order.where(market_id: market.id, order_type:'LIMIT_BUY', account_id: 1).last
    end
  end
end