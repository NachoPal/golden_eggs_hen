module WalletService
  class Create

    def fire!(currency, quantity, rate)
      new_wallet = Wallet.new(account_id: 1, currency_id: currency.id, balance: quantity,
                              available: quantity, pending: BigDecimal.new(0))

      new_wallet.save

      #Restar inversion de BTC wallet

      btc_wallet = Wallet.joins(:currency).where(currencies: {name: BASE_MARKET }).first
      btc_wallet.update(available: btc_wallet.available - quantity * rate,
                        balance: btc_wallet.balance - quantity * rate)

      new_wallet
    end
  end
end