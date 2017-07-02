namespace :buy do

  desc 'Buy markets'
  task :markets, [:iteration_number] => :environment do |t, args|
    markets = Bittrex.client.get('public/getmarketsummaries')

    percentile = MarketService::PercentileVolume.new.fire!(markets, PERCENTILE)

    markets.each do |market|

      #next if market['MarketName'] != 'BTC-LTC'
      currencies = market['MarketName'].split('-')
      price = market['Last']
      #ask_price = market['Ask']


      next if MarketService::Exclude.new.fire!(currencies, market['Volume'], percentile)

      market_record = MarketService::Retrieve.new.fire!(market, currencies, price)

      # Rails.logger.info "--------------------- #{market['MarketName']} ----------------------------"
      # Rails.logger.info "#{market_record.price}"
      # Rails.logger.info "#{price}"
      # Rails.logger.info "---------------------------------------------"

      #MarketService::SaveInCache.new.fire!(market_record.id, price)

      # Rake::Task['populate:wallets'].reenable
      # #TODO: Select proper account
      # Rake::Task['populate:wallets'].invoke(1)

      #wallets = WalletService::Retrieve.new.fire!
      enough = WalletService::EnoughMoney.new.fire!(BASE_MARKET)

      if enough
        buy = MarketService::ShouldBeBought.new.fire!(market_record, price)

        if buy
          order = OrderService::Buy.new.fire!(market_record)
          if order[:success]
            TransactionService::Create.new.fire!(order[:record])
            #limit = OrderService::SetLostLimit.new.fire!(order[:record], 'first')
            #market_to_sell_id = order[:record].market.id
            #OrderService::Sell.new.fire!(market_to_sell_id , limit[:rate], limit[:quantity])
          end
        end
      end

      if market_record.price != price && (args[:iteration_number] % UPDATE_MARKET_DB_EACH_X_MIN) == 0
        MarketService::Update.new.fire!(market_record, price)
      end

    end
  end
end
