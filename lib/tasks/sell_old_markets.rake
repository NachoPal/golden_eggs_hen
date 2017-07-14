namespace :sell do

  desc 'Sell old markets'
  task :old_markets => :environment do

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

    def benefit_last_day
      beginning_of_day = Time.zone.now.beginning_of_day

      transactions = Transactionn.where.not(benefit: nil).where('created_at > ?', beginning_of_day)
      num_transactions = transactions.count
      benefit = transactions.map(&:percentage).reduce { |sum,n| sum+=n }

      benefit - (num_transactions * COMMISSION * 2)
    end

    num_wallets = Wallet.count

    if num_wallets > (NUM_MARKETS_TO_BUY + 1)
      transaction_time = Transactionn.all.order(created_at: :asc).first.created_at
      now_time = Time.zone.now

      time_ago = (now_time - transaction_time) / 60

      if time_ago >= 60
        growth_hash = []
        benefit = 0

        Transactionn.where.not(benefit: nil).each do |transaction|
          market_name = transaction.last.market.name
          buy_price = transaction.buys.first.limit_price
          current_price = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first['Last']

          growth = (((current_price * 100) / buy_price) - 100).round(2)
          growth_hash << {id: transaction.id, growth: growth}
        end

        growth_hash = growth_hash.sort_by { |transaction| transaction[:growth] }.reverse

        growth_hash.each do |transaction|
          transaction_record = Transactionn.find(transaction.id)
          market = transaction_record.market
          market_name = market.name.split('-').last
          buy_order = transaction_record.buys.first
          wallet = Wallet.joins(:currency).where(currencies: {name: market_name}).first

          benefit =

          OrderService::Sell.new.fire!(buy_order, wallet, market, true)
          has_been_sold(wallet, transaction, market_name, market)
        end
      end
    end
  end
end