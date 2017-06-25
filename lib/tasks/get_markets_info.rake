namespace :get do

  desc 'Get markets info'
  task :markets_info => :environment do
    markets = Bittrex.client.get('public/getmarketsummaries')

    MARKET_REQUEST_COUNTER += 1

    markets.each do |market|

      currencies = market['MarketName'].split('-')
      price = market['Last']

      next if !BUY_ETH_MARKET && currencies.first == 'ETH'
      next if !BUY_BITCNY_MARKET && currencies.first == 'BITCNY'
      next if !BUY_USDT_MARKET && currencies.first == 'USDT'

      market_record = Market::CheckIfPresent.new.fire!(market, currencies, price)

      Market::SaveInCache.new.fire!(market_record.id, price)

      #Market::Buy.new.fire!(market_record.id, price)

      # Rake::Task['save:market_in_cache'].reenable
      # Rake::Task['save:market_in_cache'].invoke(market_record.id, price)

      # Rake::Task['check:market_to_buy'].reenable
      # Rake::Task['check:market_to_buy'].invoke(market_record)

      #Dentro de este rake se tendra que fijar el stop limit (sell) e ir manteniendo
      #o cancelando la orden en funcion del nuevo valor en cache
      #Rake::Task['check:orders_to_sell'].reenable
      #Rake::Task['check:orders_to_sell'].invoke(market_record)

      puts "====================== #{MARKET_REQUEST_COUNTER} ========================="

      if market_record.price != price && (MARKET_REQUEST_COUNTER % UPDATE_MARKET_DB_EACH_X_MIN) == 0
        puts "******************** #{MARKET_REQUEST_COUNTER} *************************"
        market_record.update(price: price)
      end

    end
  end
end
