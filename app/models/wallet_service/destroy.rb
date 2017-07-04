module WalletService
  class Destroy

    def fire!(wallet, transaction)
      sell_record = transaction.sells.first
      quantity = sell_record.quantity
      rate = sell_record.limit_price

      btc_wallet = Wallet.joins(:currency).where(currencies: {name: BASE_MARKET }).first
      btc_wallet.update(available: btc_wallet.available + (quantity * rate),
                        balance: btc_wallet.balance + (quantity * rate))
      wallet.destroy
    end
  end
end