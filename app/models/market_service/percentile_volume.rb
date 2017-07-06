require 'array_stats'

module MarketService
  class PercentileVolume

    def fire!(markets)
      markets_volume = []

      markets.each do |market|
        markets_volume << market['BaseVolume'] if market['BaseVolume'].present?
      end

      markets_volume.percentile(PERCENTILE_VOLUME)
    end
  end
end