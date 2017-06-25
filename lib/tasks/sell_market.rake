namespace :sell do

  desc 'Sell market'
  task :market, [:market_record, :rate, :quantity] => :environment do |t, args|

    Bittrex.client.get("market/selllimit?market=#{args[:market_record].name}&
                        quantity=#{args[:quantity]}&rate=1.3")
  end
end