module WalletService
  class EnoughMoney

    def fire!(wallets)
      btc_wallet = wallets.joins(:currency).where(currencies: {name: 'BTC'}).first
      available = btc_wallet.available

      available >= BTC_QUANTITY_TO_BUY
    end
  end
end