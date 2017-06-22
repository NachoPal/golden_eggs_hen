namespace :get do

  desc 'Get currencies info'
  task :currencies_info, [:currency_name] => :environment do |t, args|
    args.with_defaults(currency_name: 'all')

    currencies = Bittrex.client.get('public/getcurrencies')

    currencies.each do |currency|
      if args[:currency_name] != 'all'
        next if currency['Currency'] != args[:currency_name]
      end

      unless Currency.where(name: currency['Currency']).present?
        Currency.create(name: currency['Currency'], name_long: currency['CurrencyLong'])
      end
    end
  end
end