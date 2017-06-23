namespace :get do

  desc 'Get markets info'
  task :wallets, [:account_id] => :environment do |t, args|
    args.with_defaults(account_id: 1)

    wallets = Bittrex.client.get('account/getbalances')

    wallets.each do |wallet|

      wallet_record = Wallet.joins(:currency).where(currencies: {name: wallet['Currency']}).first

      if wallet_record.present?
        wallet_record.update(balance: wallet['Balance'],
                             available: wallet['Available'],
                             pending: wallet['Pending'])


      else
        Wallet.create(account_id: args[:account_id],
                      currency_id: Currency.where(name: wallet['Currency']).first.id,
                      balance: wallet['Balance'],
                      available: wallet['Available'],
                      pending: wallet['Pending'],
                      address: wallet['CryptoAddress'])
      end
    end
  end
end