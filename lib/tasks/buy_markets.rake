namespace :buy do

  desc 'Buy markets'
  task :markets, [:iteration_number] => :environment do |t, args|
    markets = Bittrex.client.get('public/getmarketsummaries')

    markets.each do |market|

      #next if market['MarketName'] != 'BTC-LTC'
      currencies = market['MarketName'].split('-')
      price = market['Last']

      next if MarketService::Exclude.new.fire!(currencies)

      market_record = MarketService::Retrieve.new.fire!(market, currencies, price)

      Rails.logger.info "--------------------- #{market['MarketName']} ----------------------------"
      Rails.logger.info "#{market_record.price}"
      Rails.logger.info "#{price}"
      Rails.logger.info "---------------------------------------------"

      #MarketService::SaveInCache.new.fire!(market_record.id, price)

      buy = MarketService::ShouldBeBought.new.fire!(market_record, price)

      if buy
        order = OrderService::Buy.new.fire!(market_record)
        if order[:success]
          limit = OrderService::SetLostLimit.new.fire!(order[:record])
          OrderService::Sell.new.fire!(order[:record], limit[:rate], limit[:quantity])
        end
      end

      if market_record.price != price && (args[:iteration_number] % UPDATE_MARKET_DB_EACH_X_MIN) == 0
        MarketService::Update.new.fire!(market_record, price)
      end

    end
  end
end
