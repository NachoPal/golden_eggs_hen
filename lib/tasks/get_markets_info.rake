namespace :get do

  desc 'Get markets info'
  task :markets_info => :environment do
    markets = Bittrex.client.get('public/getmarketsummaries')

    markets.each do |market|
      name = market['MarketName']
      currencies = market['MarketName'].split('-')
      primary = Currency.where(name: currencies.first).first
      secondary = Currency.where(name: currencies.last).first
      price = market['Last']

      if primary.nil?
        Rake::Task['get:currencies_info'].invoke(currencies.first)
        primary = Currency.where(name: currencies.first).first
        end

      if secondary.nil?
        Rake::Task['get:currencies_info'].invoke(currencies.last)
        secondary = Currency.where(name: currencies.first).first
      end

      market_record = Market.where(name: name).first

      if market_record.present?
        market_record.update(price: price)
      else
        Market.create(name: name, primary_currency_id: primary.id, secondary_currency_id: secondary.id, price: price)
      end
    end
  end
end
