namespace :populate do

  desc 'Populate markets'
  task :markets => :environment do

    #Rake::Task['populate:currencies'].reenable
    #Rake::Task['populate:currencies'].invoke
    Rake::Task['populate:currencies'].execute

    markets = Bittrex.client.get('public/getmarketsummaries')

    markets.each do |market|

      name = market['MarketName']
      currencies = name.split('-')
      primary = Currency.where(name: currencies.first).first
      secondary = Currency.where(name: currencies.last).first
      price = market['Last']

      market_record = Market.where(name: name)

      if market_record.present?
        market_record.update(price: price)
      else
        Market.create(name: name, primary_currency_id: primary.id,
                      secondary_currency_id: secondary.id,
                      price: price)
      end
    end
  end
end