module WalletService
  class EnoughMoney

    def fire!(base_market)
      btc_wallet = Wallet.joins(:currency).where(currencies: {name: base_market}).first
      available = btc_wallet.available

      available_condition = available >= BTC_QUANTITY_TO_BUY + (BTC_QUANTITY_TO_BUY * COMMISSION / 100)
      num_wallets_condition = Wallet.count < NUM_MARKETS_TO_BUY + 1

      available_condition && num_wallets_condition
    end
  end
end