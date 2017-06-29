module WalletService
  class EnoughMoney

    def fire!(base_market)
      btc_wallet = Wallet.joins(:currency).where(currencies: {name: base_market}).first
      available = btc_wallet.available

      available >= BTC_QUANTITY_TO_BUY
    end
  end
end