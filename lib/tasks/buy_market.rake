namespace :buy do

  desc 'Buy market'
  task :market, [:market_record, :rate, :quantity] => :environment do |t, args|

=begin
    order = Bittrex.client.get("market/buylimit?market=#{args[:market_record].name}&
                                quantity=#{args[:quantity]}&rate=#{args[:rate]}")

    if order['success']
      true
    else
      false
    end

    # LLamar a la orden y crear registro en la base de datos

=end

    Order.create(account_id: 1, market_id: args[:market_record].id,
                 order_type: 'LIMIT_BUY', limit_price: args[:rate],
                 quantity: args[:quantity],
                 quantity_remaining: BigDecimal.new(0))


  end
end