namespace :monitorize do

  desc 'Monitorize markets'
  task :markets => :environment do

    markets = Bittrex.client.get('public/getmarketsummaries')

    markets.delete_if do |market|
      market['MarketName'].split('-').first == 'ETH'
    end

    markets.each do |market|
      MarketService::SaveInCache.new.fire!(market['MarketName'], market['Last'])
    end
  end
end