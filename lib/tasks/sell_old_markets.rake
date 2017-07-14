#1.- Pensar bien el benefit del last day, xq cuando empiece el nuevo dia, aun teniendo
#dinero ganado no venderá nada xq el beneficio del dia se pondrá a 0

#2.- Vender a la hora si no se ha vendido aun ademas de mirar a la hora si ha pasado
#una hora desde la ultima venta

#3.- Esta comprando mas de 10 carteras, arreglar eso en ThereIsEnough money. POsiblemente
#meter un condicional con el numero de carteras maximo

#4.- Arreglar (benefit_last_day * PERCENTAGE_TO_LOSE_OLD_MARKETS) condicional, esta mal

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
    sells = Sell.where(open: false).order(created_at: :desc)

    if num_wallets == (NUM_MARKETS_TO_BUY + 1) && sells.present?

      transaction_time = sells.last.created_at
      #transaction_time = Transactionn.all.order(created_at: :desc).first.created_at
      now_time = Time.zone.now

      time_ago = (now_time - transaction_time) / 60

      if time_ago >= SELL_OLD_MARKETS_PERIOD
        growth_hash = []
        Rails.logger.info "========= ENTRA ========="
        Transactionn.where(benefit: nil).each do |transaction|
          market_name = transaction.market.name
          buy_price = transaction.buys.first.limit_price
          current_price = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first['Last']

          growth = (((current_price * 100) / buy_price) - 100).round(2)
          growth_hash << {id: transaction.id, growth: growth} if growth < 0
        end

        growth_hash = growth_hash.sort_by { |transaction| transaction[:growth] }.reverse

        growth_hash.each do |transaction|
          transaction_record = Transactionn.find(transaction[:id])
          market = transaction_record.market
          currency = market.name.split('-').last
          market_name = "#{BASE_MARKET}-#{currency}"
          buy_order = transaction_record.buys.first
          wallet = Wallet.joins(:currency).where(currencies: {name: currency}).first

          Rails.logger.info "#{transaction} -- #{transaction[:growth].to_f}"
          Rails.logger.info "#{benefit_last_day}"

          if (benefit_last_day * PERCENTAGE_TO_LOSE_OLD_MARKETS) > -(transaction[:growth])
            OrderService::Sell.new.fire!(buy_order, wallet, market, true)
            has_been_sold(wallet, transaction_record, market_name, market)
          else
            break
          end
        end
      end
    end
  end
end