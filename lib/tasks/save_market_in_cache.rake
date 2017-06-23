namespace :save do

  desc 'Save markets info cache'
  task :market_in_cache, [:market_record_id,:current_market_price] => :environment do |t, args|
    Rails.cache.fetch("markets/#{args[:market_record_id]}", expires_in: 24.hours) do
      args[:current_market_price]
    end
  end
end