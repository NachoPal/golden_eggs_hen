module Market
  class Update

    def fire!(market, price)
      market.update(price: price)
    end
  end
end