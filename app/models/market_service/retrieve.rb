module MarketService
  class Retrieve

    def fire! (market, currencies, price, volume)
      name = market['MarketName']

      unless currencies_present?(currencies)
        primary = Currency.where(name: currencies.first).first
        secondary = Currency.where(name: currencies.last).first

        Market.create(name: name, primary_currency_id: primary.id,
                      secondary_currency_id: secondary.id,
                      price: price, volume: volume)
      end
      Market.where(name: name).first
    end

    private

    def currencies_present?(currencies)
      primary = Currency.where(name: currencies.first).first
      secondary = Currency.where(name: currencies.last).first

      present = true

      [primary, secondary].each do |currency|
         if currency.nil?
           Rake::Task['populate:currencies'].reenable
           Rake::Task['populate:currencies'].invoke(currency)
           present = false
         end
      end
      present
    end
  end
end