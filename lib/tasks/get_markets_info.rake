namespace :get do

  desc 'Get markets info'
  task :markets_info => :environment do
    markets = Bittrex.client.get('public/getmarketsummaries')

    MARKET_REQUEST_COUNTER += 1

    puts "====================== #{MARKET_REQUEST_COUNTER} ========================="

    markets.each do |market|

      currencies = market['MarketName'].split('-')
      price = market['Last']

      next if Market::Exclude.new.fire!(market, currencies)

      market_record = Market::Retrieve.new.fire!(market, currencies, price)

      Market::SaveInCache.new.fire!(market_record.id, price)

      buy = Market::ShouldBeBought.new.fire!(market_record)

      order = Order::Buy.new.fire!(market_record) if buy

      if order[:success]
        limit = Order::SetLostLimit.new.fire!(order[:record])
        Order::Sell.new.fire!(order, limit[:rate], limit[:quantity])
      end

      if market_record.price != price && (MARKET_REQUEST_COUNTER % UPDATE_MARKET_DB_EACH_X_MIN) == 0
        Market::Update.new.fire!(market_record, price)
      end
    end
  end
end
