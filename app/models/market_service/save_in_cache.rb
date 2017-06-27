module MarketService
  class SaveInCache

    def fire!(market_id, price)
      Rails.cache.fetch("#{market_id}/markets", expires_in: 24.hours) do
        price
      end
    end

  end
end