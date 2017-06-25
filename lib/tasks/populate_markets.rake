namespace :populate do

  desc 'Populate markets'
  task :markets => :environment do
    markets = Bittrex.client.get('public/getmarketsummaries')

    markets.each do |market|

      currencies = market['MarketName'].split('-')
      price = market['Last']

      #next if Market::Exclude.new.fire!(market, currencies)

      Market::Retrieve.new.fire!(market, currencies, price)
    end
  end
end