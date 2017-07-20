module MarketService
  class ShouldBeSold

    def fire!(buy_order)
      # buy_order_price = buy_order.limit_price
      #
      # market_name = buy_order.transactionn.market.name
      # market = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first
      # market_price = market['Last']
      #
      # lose_money = market_price <= ((100 - THRESHOLD_OF_LOST) * buy_order_price) / 100
      # #gain_money = market_price >= ((100 + THRESHOLD_OF_GAIN) * buy_order_price) / 100
      #
      # #lose_money || gain_money

      num_wallets = Wallet.count

      #if num_wallets == (NUM_MARKETS_TO_BUY + 1)

        time_limit = (SELL_OLD_MARKETS_PERIOD).minute.ago
        transaction = buy_order.transactionn
        market = transaction.market
        market_name = market.name
        buy_price = buy_order.limit_price
        market_info = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first
        current_price = market_info['Bid']
        ask = market_info['Ask']
        last_price = market_info['Last']
        growth = (((current_price * 100) / buy_price) - 100).round(2)


        if CACHE.get('Sky Rocket').present?
          #benefit = benefit_last_day * 0.5
          #return benefit > -growth
          return true
        end

        if transaction.created_at < time_limit && growth < COMMISSION * 2
          #growth_hash << {id: transaction.id, growth: growth} if growth < 0

          benefit = benefit_last_day * PERCENTAGE_TO_LOSE_OLD_MARKETS

          if benefit == 0
            return growth >= 0.5
          end

          return benefit > -growth
        end

        if growth <= -5 &&
          #time_limit = (5).minute.ago

          # transactions = Transactionn.joins([:account, :market]).
          #                             where(accounts: {id: 1}, markets: {id: market.id}).
          #                             where.not(benefit:nil).
          #                             where('transactionns.created_at > ?', time_limit)

          #return false unless transactions.present?

          #transactions_benefit = transactions.map(&:percentage).reduce { |sum,n| sum+=n }

          #benefit = benefit_last_day * PERCENTAGE_TO_LOSE_OLD_MARKETS
          #benefit = benefit_last_day * 0.5

          #benefit = benefit_last_day

          #growth <= -(transactions_benefit * 0.5)

          market_growth = MarketService::GetFromCache.new.fire!(market_name, 5)

          market_growth >= 10 && ask < last_price

          #return benefit > -growth if transactions_benefit >= 9
        end
      #end
    end

    private

    def benefit_last_day
      beginning_of_day = Time.zone.now - 24.hour

      transactions = Transactionn.where.not(benefit: nil).where('created_at > ?', beginning_of_day)
      num_transactions = transactions.count
      benefit = transactions.map(&:percentage).reduce { |sum,n| sum+=n }

      if benefit.present?
        benefit - (num_transactions * COMMISSION * 2)
      else
        0
      end
    end
  end
end