module OrderService
  class Sell
    def fire!(buy_order)

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
      market_name = "#{BASE_MARKET}-#{currency}"
      bid_orders = check_bid_orders(market_name)

      bid_orders.each do |bid_order|
        if bid_order['Quantity'] >= wallet.balance

          market_id = get_market_to_sell_id(market_name)
          buy_record = get_peer_buy_order(market_id)

          lose_threshold_price = ((100 - THRESHOLD_OF_LOST) * buy_record.limit_price) / 100

          if bid_order['Rate'] >= lose_threshold_price
            order = sell(market_name, bid_order['Rate'], wallet.balance, true)
          else
            order = sell(market_name, lose_threshold_price, wallet.balance, false)
          end

          order.merge!({buy_record: buy_record})
          break
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

    def sell(market, price, quantity, success)
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
      sell_order = Sell.new(limit_price: price,
                            quantity: quantity,
                            quantity_remaining: BigDecimal.new(0),
                            open: !success)



      order_record = Order.create(account_id: 1, market_id: Market.where(name: market).first.id,
                                  order_type: 'LIMIT_SELL',

      {success: success, sell_record: order_record}
    end

    def get_market_to_sell_id(name)
      Market.where(name: name).first.id
    end

    def get_peer_buy_order(id)
      Order.where(market_id: id, order_type: 'LIMIT_BUY').last
    end


  end
end