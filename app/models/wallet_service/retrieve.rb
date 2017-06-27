module WalletService
  class Retrieve

    def fire!
      #TODO: select proper Account
      Wallet.where(account_id: 1).all
    end
  end
end