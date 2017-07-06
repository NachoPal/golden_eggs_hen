module MarketService
  class PercentileAskBidProp

    def fire!(markets)
      ask_bid_prop = []

      markets.each do |market|
        ask_bid_prop << market[:quantity_prop]
      end

      ask_bid_prop.percentile(PERCENTILE_ASK_BID)
    end
  end
end