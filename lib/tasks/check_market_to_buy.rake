namespace :check do

  desc 'Check market to buy'
  task :market_to_buy, [:market_record] => :environment do |t, args|
    current_price = Rails.cache.fetch("markets/#{args[:market_record].id}")
    stored_price = args[:market_record].price
    Rails.logger.info "#{current_price} - #{stored_price}"

    #if current_price =! 0.0 && stored_price =! 0.0
      growth = ((current_price * 100) / stored_price).round(2) - 100
    #else
      #growth = 0.00
    #end

    Rails.logger.info "#{args[:market_record].name} ---- #{growth}%"

    if growth >= THRESHOLD_TO_BUY
      Rake::Task['buy:market'].reenable
      Rake::Task['buy:market'].invoke(args[:market_record].name)
    end
  end
end