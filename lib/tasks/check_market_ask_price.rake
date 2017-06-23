namespace :check do

  desc 'Check market ask price'
  task :market_ask_price, [:market_record] => :environment do |t, args|
    market = args[:market_record].name

    ask_orders = Bittrex.client.get("public/getorderbook?market=#{market}&type=sell")

    ask_orders.each do |ask_order|
      quantity = BTC_QUANTITY_TO_BUY / ask_order['Rate']

      if quantity >= ask_order['Quantity']
        Rake::Task['buy:market'].reenable
        success = Rake::Task['buy:market'].invoke(args[:market_record],
                                                  ask_order['Rate'], quantity)
        break if success
      end
    end
  end
end