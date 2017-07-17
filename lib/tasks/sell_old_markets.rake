

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
      beginning_of_day = Time.zone.now - 24.hour

      transactions = Transactionn.where.not(benefit: nil).where('created_at > ?', beginning_of_day)
      num_transactions = transactions.count
      benefit = transactions.map(&:percentage).reduce { |sum,n| sum+=n }

      benefit - (num_transactions * COMMISSION * 2)
    end

    num_wallets = Wallet.count
    sells = Sell.where(open: false).order(created_at: :desc)

    if num_wallets == (NUM_MARKETS_TO_BUY + 1) && sells.present?

      growth_hash = []
      Rails.logger.info "========= ENTRA ========="
      time_limit = (SELL_OLD_MARKETS_PERIOD - 5).minute.ago
      transactions_to_sell = Transactionn.where(benefit: nil).where('created_at < ?', time_limit)

      transactions_to_sell.each do |transaction|
        market_name = transaction.market.name
        buy_price = transaction.buys.first.limit_price
        current_price = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first['Bid']

        growth = (((current_price * 100) / buy_price) - 100).round(2)
        growth_hash << {id: transaction.id, growth: growth} if growth < 0
      end

      #growth_hash = growth_hash.sort_by { |transaction| transaction[:growth] }.reverse
      growth_hash = growth_hash.sort_by { |transaction| transaction[:growth] }

      benefit = benefit_last_day * PERCENTAGE_TO_LOSE_OLD_MARKETS
      to_sell = []

      growth_hash.each do |transaction|
        Rails.logger.info "#{transaction} -- #{transaction[:growth].to_f}"
        Rails.logger.info "#{benefit_last_day}"

        sum_lost = -(transaction[:growth])

        if benefit > sum_lost
          to_sell << transaction
          benefit -= sum_lost + (COMMISSION * 2)
        else
          next
        end
      end

      to_sell.each do |transaction|
        transaction_record = Transactionn.find(transaction[:id])
        market = transaction_record.market
        currency = market.name.split('-').last
        market_name = "#{BASE_MARKET}-#{currency}"
        buy_order = transaction_record.buys.first
        wallet = Wallet.joins(:currency).where(currencies: {name: currency}).first

        OrderService::Sell.new.fire!(buy_order, wallet, market, true)
        has_been_sold(wallet, transaction_record, market_name, market)
      end
    end
  end
end