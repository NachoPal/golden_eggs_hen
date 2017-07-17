namespace :sell do

  desc 'Sell markets'
  task :markets => :environment do

    def has_been_sold(wallet, transaction, market_name, market)
      TransactionService::Close.new.fire!(transaction)
      WalletService::Destroy.new.fire!(wallet, transaction)

      market_get = Bittrex.client.get("public/getmarketsummary?market=#{market_name}")
      current_price = market_get.first['Last']
      current_volume = market_get.first['BaseVolume']
      ask = market_get.first['Ask']
      bid = market_get.first['Bid']

      #ask_bid_stats = MarketService::OrderBookStats.new.fire!(market_get)

      MarketService::Update.new.fire!(market, current_price, current_volume, ask, bid) #, ask_bid_stats)
    end

    wallets = WalletService::Retrieve.new.fire!

    wallets.each do |wallet|
      currency = wallet.currency.name
      market_name = "#{BASE_MARKET}-#{currency}"
      market = Market.where(name: market_name).first

      next if currency == BASE_MARKET

      buy_order = OrderService::FindBuy.new.fire!(market)

      transaction = buy_order.transactionn

      open_sell = OrderService::SellExists.new.fire!(buy_order)
      sold = false

      if open_sell[:exists]
        sold = OrderService::Sold.new.fire!(open_sell[:order], market_name)
      end

      if sold
        has_been_sold(wallet, transaction, market_name, market)
      else
        if MarketService::ShouldBeSold.new.fire!(buy_order)
          if OrderService::Sell.new.fire!(buy_order, wallet, market, true)
            has_been_sold(wallet, transaction, market_name, market)
          end
        end
      end
    end
  end
end