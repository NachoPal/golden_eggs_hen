namespace :sell do

  desc 'Sell markets'
  task :markets => :environment do

    def has_been_sold(wallet, transaction, market_name, market)
      TransactionService::Close.new.fire!(transaction)
      WalletService::Destroy.new.fire!(wallet, transaction)

      current_price = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first['Last']
      MarketService::Update.new.fire!(market, current_price)
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

      if open_sell[:exists]
        if OrderService::Sold.new.fire!(open_sell[:order], market_name)
          has_been_sold(wallet, transaction, market_name, market)
        end
      else
        if MarketService::ShouldBeSold.new.fire!(buy_order)
          if OrderService::Sell.new.fire!(buy_order, wallet, market)
            has_been_sold(wallet, transaction, market_name, market)
          end
        end
      end
    end
  end
end