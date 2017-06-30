module WalletService
  class Create

    def fire!(currency, quantity, rate)
      Wallet.create(account_id: 1, currency_id: currency.id, balance: quantity,
                    available: quantity, pending: BigDecimal.new(0))

      #Restar inversion de BTC wallet

      btc_wallet = Wallet.joins(:currency).where(currencies: {name: BASE_MARKET }).first
      btc_wallet.update(available: btc_wallet.available - quantity * rate,
                        balance: btc_wallet.balance - quantity * rate)
    end
  end
end