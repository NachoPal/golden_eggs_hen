module MarketService
  class SaveInCache

    def fire!(market, price)
      if CACHE.get(market).nil?
        array_prices = Array.new(LENGTH_ARRAY_PRICES)
        CACHE.set(market, array_prices)
      else
        array_prices = CACHE.get(market)
        array_prices.push(price)
        array_prices.shift
        CACHE.set(market, array_prices)
      end
    end

  end
end