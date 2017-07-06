namespace :buy do

  desc 'Buy markets'
  task :markets, [:iteration_number] => :environment do |t, args|
    markets = Bittrex.client.get('public/getmarketsummaries')

    percentile_volume = MarketService::PercentileVolume.new.fire!(markets)

    markets.delete_if do |market|
      currencies = market['MarketName'].split('-')
      MarketService::Exclude.new.fire!(currencies, market['BaseVolume'], percentile_volume)
    end

    ask_bid_stats = MarketService::OrderBookStats.new.fire!(markets)
    percentile_ask_bids = MarketService::PercentileAskBidProp.new.fire!(ask_bid_stats)

    #Rails.logger.info "Percentile: #{percentile}"

    markets.each do |market|
      currencies = market['MarketName'].split('-')
      price = market['Last']

      market_record = MarketService::Retrieve.new.fire!(market, currencies, price)

      if WalletService::EnoughMoney.new.fire!(BASE_MARKET)
        if MarketService::ShouldBeBought.new.fire!(market_record, price, ask_bid_stats, percentile_ask_bids)
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
