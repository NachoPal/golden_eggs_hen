namespace :populate do

  desc 'Get wallets'
  task :wallets, [:account_id] => :environment do |t, args|
    args.with_defaults(account_id: 1)

    #================= LIVE ==============================
    # wallets = Bittrex.client.get('account/getbalances')
    #
    # wallets.each do |wallet|
    #
    #   wallet_record = Wallet.joins(:currency).
    #                          where(currencies: {name: wallet['Currency']},
    #                          wallets: {account_id: args[:account_id]}).first
    #
    #   if wallet_record.present?
    #     wallet_record.update(balance: wallet['Balance'],
    #                          available: wallet['Available'],
    #                          pending: wallet['Pending'])
    #
    #
    #   else
    #     Wallet.create(account_id: args[:account_id],
    #                   currency_id: Currency.where(name: wallet['Currency']).first.id,
    #                   balance: wallet['Balance'],
    #                   available: wallet['Available'],
    #                   pending: wallet['Pending'],
    #                   address: wallet['CryptoAddress'])
    #   end
    # end
    #======================================================

    btc_wallet = Wallet.joins(:currency).where(currencies: {name: 'BTC'}).first

    if btc_wallet.present?
      btc_wallet.update(balance: BigDecimal.new(0.005),
                        available: BigDecimal.new(0.005),
                        pending: BigDecimal.new(0))
    else
      Wallet.create(account_id: 1,
                    balance: BigDecimal.new(0.005),
                    available: BigDecimal.new(0.005),
                    currency_id: Currency.where(name: 'BTC').first.id)
    end
  end
end