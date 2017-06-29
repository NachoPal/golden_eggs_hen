module OrderService
  class Sell
    def fire!(wallet, currency_exchange)

      #============ LIVE ==============
      # Bittrex.client.get("market/selllimit?market=#{order.market.name}&
      #                   quantity=#{quantity}&rate=#{rate}")

      # #TODO: Select proper account
      # Rails.logger.info "============= ENTRA EN CREATE ==============="
      # Order.create(account_id: 1, market_id: market_id,
      #              order_type: 'LIMIT_SELL', limit_price: rate,
      #              quantity: quantity, open: true,
      #              quantity_remaining: BigDecimal.new(0))

      order = {success: false, sell_record: nil}

      currency = wallet.currency.name
      market_name = "#{currency_exchange}-#{currency}"
      bid_orders = check_bid_orders(market_name)

      bid_orders.each do |bid_order|
        if bid_order['Quantity'] >= wallet.balance
          order = sell(market_name, bid_order['Rate'], wallet.balance)

          if order[:success]
            market_id = get_market_to_sell_id(market_name)
            buy_record = get_peer_buy_order(market_id)
            order.merge!({buy_record: buy_record})
            break
          end
        else
          next
        end
      end
      order
    end

    private

    def check_bid_orders(market)
      Bittrex.client.get("public/getorderbook?market=#{market}&type=buy")
    end

    def sell(market, price, quantity)
    # #============= LIVE =================================
    # order = Bittrex.client.get("market/selllimit?market=#{args[:market_record].name}&
    #                           quantity=#{args[:quantity]}&rate=#{args[:rate]}")
    #
    # if order['success']
    #   Crear nuevo Order record en la base de datos
    #   {success: true, record: order_record}
    # else
    #   {success: false, record: nil}
    # end

    #TODO: Select proper account
    order_record = Order.create(account_id: 1, market_id: Market.where(name: market).first.id,
                                order_type: 'LIMIT_SELL', limit_price: price,
                                quantity: quantity,
                                quantity_remaining: BigDecimal.new(0),
                                open: false)

    {success: true, sell_record: order_record}
    end

    def get_market_to_sell_id(name)
      Market.where(name: name).first.id
    end

    def get_peer_buy_order(id)
      Order.where(market_id: id, order_type: 'LIMIT_BUY').last
    end


  end
end