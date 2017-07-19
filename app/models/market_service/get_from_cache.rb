module MarketService
  class GetFromCache

    def fire!(market, time_ago)
      begin
        array_prices = CACHE.get(market)
        #Rails.logger.info "GET - > Market: #{market} -- value: #{array_prices}\n\n"
        #return 0 if array_prices.nil?
        steps = time_ago * 60 / PERIOD_SEG

        array_prices.last(steps).delete(nil)

        #(array_prices.last * 100 / array_prices.first) - 100

        growth = (array_prices.last * 100 / array_prices.first) - 100

        Rails.logger.info "Market: #{market} -- Growth: #{growth}" if growth >= 10

        growth

      rescue  => e
        Rails.logger.info "Error: #{e}"
        Rails.logger.info "GET - > Market: #{market} -- value: #{array_prices}\n\n"
        return 0
      end
    end
  end
end