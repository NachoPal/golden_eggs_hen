require 'rufus-scheduler'
require 'rake'

Rails.application.load_tasks

s = Rufus::Scheduler.singleton

unless defined?(Rails::Console)
  market_request_counter = 0

  s.every '10s' do
    market_request_counter += 1
    puts "====================== #{market_request_counter} ========================="

    Rake::Task['buy:markets'].reenable
    Rake::Task['buy:markets'].invoke(market_request_counter)

    #Rake::Task['sell:markets'].reenable
    #Rake::Task['sell:markets'].execute

    if (args[:iteration_number] % UPDATE_MARKET_DB_EACH_X_MIN) == 0
      market_request_counter = 0
    end
  end
end