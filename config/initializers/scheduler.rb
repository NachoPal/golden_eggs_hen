require 'rufus-scheduler'
require 'rake'

Rails.application.load_tasks

s = Rufus::Scheduler.singleton
market_request_counter = 0

unless defined?(Rails::Console)

  s.in '0.1s' do
    Order.destroy_all
    Wallet.destroy_all
    Rake::Task['destroy:markets'].execute
    Rake::Task['populate:markets'].execute

    #TODO: Select proper account
    Rake::Task['populate:wallets'].invoke(1)
    puts "====================== DESTRUYO ========================="
  end

  s.every '10s' do
    market_request_counter += 1
    puts "====================== #{market_request_counter} ========================="

    Rake::Task['buy:markets'].reenable
    Rake::Task['buy:markets'].invoke(market_request_counter)

    Rake::Task['sell:markets'].reenable
    Rake::Task['sell:markets'].execute

    if (market_request_counter % UPDATE_MARKET_DB_EACH_X_MIN) == 0
      market_request_counter = 0
    end
  end
end