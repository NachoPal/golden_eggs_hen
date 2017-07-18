module MarketService
  class GetFromCache

    def fire!(market, time_ago)
      array_prices = CACHE.get(market)
      steps = time_ago / PERIOD_SEG

      array_prices.last(steps).delete(nil)

      (array_prices.last * 100 / array_prices.first) - 100
    end
  end
end