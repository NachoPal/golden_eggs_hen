namespace :get do

  desc 'Get markets info'
  task :markets_info => :environment do
    markets = Bittrex.client.get('public/getmarketsummaries')

    markets.each do |market|
      name = market['MarketName']
      currencies = market['MarketName'].split('-')
      primary = Currency.where(name: currencies.first).first.id
      secondary = Currency.where(name: currencies.last).first.id
      price = market['Last']

      if primary.nil?
        Rake::Task['get:currencies_info'].invoke(currencies.first)
        primary = Currency.where(name: currencies.first).id
        end

      if secondary.nil?
        Rake::Task['get:currencies_info'].invoke(currencies.last)
        secondary = Currency.where(name: currencies.first).id
      end

      #market_record = Market.where(primary_currency_id: primary, secondary_currency_id: secondary)
      market_record = Market.where(name: name).first

      if market_record.present?
        market_record.update(price: price)
      else
        Market.create(name: name,primary_currency_id: primary, secondary_currency_id: secondary, price: price)
      end
    end
  end
end
