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

    sorted_wallets = []

    markets = Bittrex.client.get("public/getmarketsummaries")

    wallets.each do |wallet|
      currency = wallet.currency
      next if currency.name == BASE_MARKET
      market = currency.market
      transaction = market.transactionns.where(account_id: 1).last
      buy_price = transaction.buys.first.limit_price
      current_price = markets.select { |m| m['MarketName']== market.name }.first['Bid']

      growth = (((current_price * 100) / buy_price) - 100).round(2)

      sorted_wallets << {wallet: wallet,
                         market: market,
                         buy_order: transaction.buys.first,
                         transaction: transaction,
                         growth: growth}
    end

    sorted_wallets.sort_by! {|wallet| wallet[:growth]}.reverse

    sorted_wallets.each do |wallet|

      buy_order = wallet[:buy_order]
      market = wallet[:market]
      transaction = wallet[:transaction]
      wallet = wallet[:wallet]

      open_sell = OrderService::SellExists.new.fire!(buy_order)
      sold = false

      if open_sell[:exists]
        sold = OrderService::Sold.new.fire!(open_sell[:order], market.name)
      end

      if sold
        has_been_sold(wallet, transaction, market.name, market)
      else
        if MarketService::ShouldBeSold.new.fire!(buy_order)
          if OrderService::Sell.new.fire!(buy_order, wallet, market, true)
            has_been_sold(wallet, transaction, market.name, market)
          end
        end
      end
    end
  end
end