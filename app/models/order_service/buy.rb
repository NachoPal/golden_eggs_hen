module OrderService
  class Buy

    #TODO: I have to check if it's worth it to buy to the success ask order price
    def fire!(market)
      ask_orders = check_ask_orders(market.name)
      order = {success: false, record: nil}

      ask_orders.each do |ask_order|
        quantity = BTC_QUANTITY_TO_BUY / ask_order['Rate']

        if quantity >= ask_order['Quantity']
          #Here is where I should add an IF to check the final order price
          #If is not worth it I return {success: false, order: nil}
          order = buy(market, ask_order['Rate'], quantity: quantity)
          break if order[:success]
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
                                  quantity_remaining: BigDecimal.new(0))

      {success: true, record: order_record}
    end
  end
end