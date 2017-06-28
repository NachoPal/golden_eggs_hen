module OrderService
  class Buy

    #TODO: I have to check if it's worth it to buy to the success ask order price
    def fire!(market)
      ask_orders = check_ask_orders(market.name)
      order = {success: false, record: nil}

      ask_orders.each do |ask_order|
        quantity = BTC_QUANTITY_TO_BUY / ask_order['Rate']

        if quantity <= ask_order['Quantity']
          #Here is where I should add an IF to check the final order price
          #If is not worth it I return {success: false, order: nil}
          order = buy(market, ask_order['Rate'], quantity)

          # filename = Rails.root + 'history.pdf'
          # Prawn::Document.generate('history.pdf', :template => filename) do
          #   text "\nBUY ----------- #{market.name} ----------------"
          # end

          #============ Rellenar Walllet (solo virtual)==================
          currency = Currency.where(name: market.name.split('-').last).first

          Wallet.create(account_id: 1, currency_id: currency.id, balance: quantity*ask_order['Rate'],
                        available: quantity*ask_order['Rate'], pending: BigDecimal.new(0))

          #Restar inversion de BTC wallet

          btc_wallet = Wallet.joins(:currency).where(currencies: {name: 'BTC'}).first
          btc_wallet.update(available: btc_wallet.available - quantity*ask_order['Rate'],
                            balance: btc_wallet.balance - quantity*ask_order['Rate'])

          # Prawn::Document.generate('history.pdf', :template => filename) do
          #   text "Rate: #{ask_order['Rate']}"
          #   text "Quantity: #{quantity*ask_order['Rate']}"
          # end

          #==============================================================

          break if order[:success]
        else
          next
        end
      end
      order
    end

    private

    def check_ask_orders(market)
      Bittrex.client.get("public/getorderbook?market=#{market}&type=sell")
    end

    def buy(market, price, quantity)
      # #============= LIVE =================================
      # order = Bittrex.client.get("market/buylimit?market=#{args[:market_record].name}&
      #                           quantity=#{args[:quantity]}&rate=#{args[:rate]}")
      #
      # if order['success']
      #   Crear nuevo Order record en la base de datos
      #   {success: true, record: order_record}
      # else
      #   {success: false, record: nil}
      # end

      #TODO: Select proper account
      order_record = Order.create(account_id: 1, market_id: market.id,
                                  order_type: 'LIMIT_BUY', limit_price: price,
                                  quantity: quantity,
                                  quantity_remaining: BigDecimal.new(0),
                                  open: false)

      {success: true, record: order_record}
    end
  end
end