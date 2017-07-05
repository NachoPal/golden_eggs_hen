namespace :buy do

  desc 'Buy markets'
  task :markets, [:iteration_number] => :environment do |t, args|
    markets = Bittrex.client.get('public/getmarketsummaries')

    percentile = MarketService::PercentileVolume.new.fire!(markets, PERCENTILE)

    Rails.logger.info "Percentile: #{percentile}"

    markets.each do |market|

      currencies = market['MarketName'].split('-')
      price = market['Last']

      next if MarketService::Exclude.new.fire!(currencies, market['BaseVolume'], percentile)

      market_record = MarketService::Retrieve.new.fire!(market, currencies, price)

      if WalletService::EnoughMoney.new.fire!(BASE_MARKET)
        if MarketService::ShouldBeBought.new.fire!(market_record, price)
          bought = OrderService::Buy.new.fire!(market_record)

          if bought[:success]
            OrderService::Sell.new.fire!(bought[:order], bought[:wallet], market_record, true)
          end
        end
      end

      if market_record.price != price && (args[:iteration_number] % UPDATE_MARKET_DB_EACH_X_MIN) == 0
        MarketService::Update.new.fire!(market_record, price)
      end
    end
  end
end
