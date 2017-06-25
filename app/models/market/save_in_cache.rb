module Market
  class SaveInCache

    def fire!(market_id, price)
      Rails.cache.fetch("markets/#{market_id}", expires_in: 24.hours) do
        price
      end
    end

  end
end