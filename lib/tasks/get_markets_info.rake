namespace :get do

  desc 'Get markets info'
  task :markets_info => :environment do
    markets = Bittrex.client.get('public/getmarketsummaries')

    MARKET_REQUEST_COUNTER += 1

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
        Rake::Task['save:market_in_cache'].reenable
        Rake::Task['save:market_in_cache'].invoke(market_record.id, price)

        Rake::Task['check:market_to_buy'].reenable
        Rake::Task['check:market_to_buy'].invoke(market_record)

        #Dentro de este rake se tendra que fijar el stop limit (sell) e ir manteniendo
        #o cancelando la orden en funcion del nuevo valor en cache

        #Rake::Task['check:orders_to_sell'].reenable
        #Rake::Task['check:orders_to_sell'].invoke(market_record)

        puts "====================== #{MARKET_REQUEST_COUNTER} ========================="

        if market_record.price != price && (MARKET_REQUEST_COUNTER % UPDATE_MARKET_DB_EACH_X_MIN) == 0
          puts "******************** #{MARKET_REQUEST_COUNTER} *************************"
          market_record.update(price: price)
        end
      else
        Market.create(name: name, primary_currency_id: primary.id, secondary_currency_id: secondary.id, price: price)
      end
    end
  end
end
