module MarketService
  class Update

    def fire!(market, price, volume)

      # ask_bid_prop = ask_bid_stats.select { |a| a[:name] == market.name }.first
      #
      # weighted_bid_mean = ask_bid_prop[:weighted_bid_mean]
      # weighted_ask_mean = ask_bid_prop[:weighted_ask_mean]
      #
      # market.update(price: price,
      #               weighted_bid_mean: weighted_bid_mean,
      #               weighted_ask_mean: weighted_ask_mean)
      #
       market.update(price: price, volume: volume)

    end
  end
end