module Order
  class Sell
    def fire!(order, rate, quantity)
      Bittrex.client.get("market/selllimit?market=#{order.market.name}&
                        quantity=#{quantity}&rate=#{rate}")
    end
  end
end