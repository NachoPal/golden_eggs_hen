require 'rufus-scheduler'
require 'rake'

Rails.application.load_tasks

start = Rufus::Scheduler.singleton
start_trade = Rufus::Scheduler.singleton
trade = Rufus::Scheduler.singleton
start_monitorize = Rufus::Scheduler.singleton
monitorize = Rufus::Scheduler.singleton

market_request_counter = 0
array_price_length = LENGTH_ARRAY_PRICES + 2

unless defined?(Rails::Console)

  start.in '0.1s' do
    CACHE.flush_all
    puts "====================== DESTRUYO ========================="
    Orderr.destroy_all
    Wallet.destroy_all
    Transactionn.destroy_all

    Rake::Task['destroy:markets'].execute
    Rake::Task['populate:markets'].execute

    #TODO: Select proper account
    Rake::Task['populate:wallets'].invoke(1)
  end

  start_monitorize.in '30s' do
    monitorize.every "#{PERIOD_SEG}s" do
      if array_price_length >= 0
        Rails.logger.info "----------------------- #{array_price_length} ---------------------------"
        Rake::Task['monitorize:markets'].reenable
        Rake::Task['monitorize:markets'].invoke
        array_price_length -= 1
      end
    end
  end

  start_trade.in "#{UPDATE_MARKET_CACHE_EACH_X_MIN + 1}m" do
    trade.every "#{PERIOD_SEG}s" do
      market_request_counter += 1
      puts "====================== #{market_request_counter} ========================="

      Rake::Task['buy:markets'].reenable
      Rake::Task['buy:markets'].invoke(market_request_counter)

      Rake::Task['sell:markets'].reenable
      Rake::Task['sell:markets'].invoke

      if (market_request_counter % LENGTH_ARRAY_PRICES) == 0
        market_request_counter = 0
      end
    end

    # s.every "#{SELL_OLD_MARKETS_PERIOD}m" do
    #   Rake::Task['sell:old_markets'].reenable
    #   Rake::Task['sell:old_markets'].invoke
    # end
  end


end

