namespace :sell do

  desc 'Sell markets'
  task :markets => :environment do

    #Rake::Task['populate:wallets'].reenable

    #wallets = WalletService::Retrieve.new.fire!



    # orders_to_sell = OrderService::Retrieve.new.fire!
    #
    # orders_to_sell.each do |order_to_sell|
    #
    #   #===== CHECK IF HAS BEEN SOLD (not live) ==============
    #   OrderService::Sold.new.fire!(order_to_sell)
    #
    #   #======================================================
    #
    #   limit = OrderService::SetLostLimit.new.fire!(order_to_sell, 'reset')
    #   Rails.logger.info "Limit rate: #{limit[:rate]}"
    #   if limit[:rate].present?
    #     market_to_sell_id = order_to_sell.market.id
    #     OrderService::Cancel.new.fire!(order_to_sell)
    #     OrderService::Sell.new.fire!(market_to_sell_id, limit[:rate], limit[:quantity])
    #   end
    #
    # end

    wallets = WalletService::Retrieve.new.fire!

    wallets.each do |wallet|
      next if wallet.currency.name == BASE_MARKET

      sell = MarketService::ShouldBeSold.new.fire!(wallet, BASE_MARKET)

      if sell
        order = OrderService::Sell.new.fire!(wallet, 'BTC')
        if order[:success]
          TransactionService::Close.new.fire!(order[:buy_record], order[:sell_record])
          WalletService::Destroy.new.fire!(wallet)
        end
      end
    end
  end
end