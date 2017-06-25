module Market
  class Exclude

    def fire!(market, currencies)
      (!BUY_ETH_MARKET && currencies.first == 'ETH') ||
      (!BUY_BITCNY_MARKET && currencies.first == 'BITCNY') ||
      (!BUY_USDT_MARKET && currencies.first == 'USDT')
    end
  end
end