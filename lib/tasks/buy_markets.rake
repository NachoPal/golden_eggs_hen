namespace :buy do

  desc 'Buy markets'
  task :markets, [:iteration_number] => :environment do |t, args|
    markets = Bittrex.client.get('public/getmarketsummaries')

    percentile_volume = MarketService::PercentileVolume.new.fire!(markets)

    markets.delete_if do |market|
      currencies = market['MarketName'].split('-')
      MarketService::Exclude.new.fire!(currencies, market['BaseVolume'], percentile_volume)
    end

    markets.each do |market|
      market['MaxDiff'] = ((market['Last'] * 100) / market['High']) - 100
      market['DailyIncrease'] = (((market['Last'] * 100) / market['PrevDay']) - 100).round(2)
    end


    markets = markets.sort_by { |market| market['DailyIncrease'] }.reverse #[0..NUM_MARKETS_TO_BUY - 1]
    #markets = markets.sort_by { |market| market['MaxDiff'] }.reverse #[0..NUM_MARKETS_TO_BUY - 1]

    #Rails.logger.info "Percentile: #{percentile}"

    markets.each do |market|
      currencies = market['MarketName'].split('-')
      price = market['Last']
      volume = market['BaseVolume']
      ask = market['Ask']
      bid = market['Bid']
      diff = market['MaxDiff']

      MarketService::SaveInCache.new.fire!(market['MarketName'], price)

      market_record = MarketService::Retrieve.new.fire!(market, currencies, price, volume)

      if WalletService::EnoughMoney.new.fire!(BASE_MARKET)
        if MarketService::ShouldBeBought.new.fire!(market_record, price, volume, ask, bid, diff, market)
          bought = OrderService::Buy.new.fire!(market_record)

          if bought[:success]
            OrderService::Sell.new.fire!(bought[:order], bought[:wallet], market_record, false)
          end
        end
      end

      if market_record.price != price && (args[:iteration_number] % LENGTH_ARRAY_PRICES) == 0
        MarketService::Update.new.fire!(market_record, price, volume, ask, bid) #, ask_bid_stats)
      end
    end
  end
end
