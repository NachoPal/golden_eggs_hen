module WalletService
  class Destroy

    def fire!(wallet)
      wallet.destroy
    end
  end
end