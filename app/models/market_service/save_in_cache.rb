module MarketService
  class SaveInCache

    def fire!(market, price)
      array_prices = CACHE.get(market)

      if array_prices.nil?
        Rails.logger.info "TRUE"
        array_prices = Array.new(LENGTH_ARRAY_PRICES)
        #Rails.logger.info "SAVE -> Market: #{market} -- value: #{array_prices}\n\n"
        CACHE.set(market, array_prices)
      else
        array_prices = CACHE.get(market)
        #Rails.logger.info "SAVE -> Market: #{market} -- value: #{array_prices}\n\n"
        array_prices.push(price)
        array_prices.shift
        CACHE.set(market, array_prices)
      end
    end
  end
end