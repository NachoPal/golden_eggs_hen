namespace :sell do

  desc 'Sell markets'
  task :markets => :environment do

    #Rake::Task['populate:wallets'].reenable

    #wallets = WalletService::Retrieve.new.fire!

    orders_to_sell = OrderService::Retrieve.new.fire!

    orders_to_sell.each do |order_to_sell|

      #===== CHECK IF HAS BEEN SOLD (not live) ==============
      OrderService::Sold.new.fire!(order_to_sell)

      #======================================================

      limit = OrderService::SetLostLimit.new.fire!(order_to_sell, 'reset')

      if limit[:rate].present?
        OrderService::Cancel.new.fire!(order_to_sell)
        OrderService::Sell.new.fire!(order_to_sell[:record], limit[:rate], limit[:quantity])
      end

    end
  end
end