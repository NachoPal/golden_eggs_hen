module Market
  class Buy

    def fire!(market)
      bought = false
      current_price = Rails.cache.fetch("markets/#{market.id}")
      stored_price = market.price
      #TODO: Take care of 0.0 prices
      growth = ((current_price * 100) / stored_price).round(2) - 100

      Rails.logger.info "#{current_price} - #{stored_price}"
      Rails.logger.info "#{args[:market_record].name} ---- #{growth}%"

      if growth >= THRESHOLD_TO_BUY && !Order.where(market_id: market.id).present?
        while !bought
          buy_info = suitable_buy_price(market)
          bought = buy(market, buy_info[:rate], buy_info[:quantity])
        end
      end
      bought
    end

    private

    def suitable_buy_price(market)
      ask_orders = Bittrex.client.get("public/getorderbook?market=#{market.name}&type=sell")

      ask_orders.each do |ask_order|
        quantity = BTC_QUANTITY_TO_BUY / ask_order['Rate']

        if quantity >= ask_order['Quantity']
          return {rate: ask_order['Rate'], quantity: quantity}
        end
      end
    end

    def buy(market, price, quantity)

      # #============= LIVE =================================
      # order = Bittrex.client.get("market/buylimit?market=#{args[:market_record].name}&
      #                           quantity=#{args[:quantity]}&rate=#{args[:rate]}")
      #
      # if order['success']
      #   Crear registro en la base de datos
      #   true
      # else
      #   false
      # end

      Order.create(account_id: 1, market_id: market.id,
                   order_type: 'LIMIT_BUY', limit_price: price,
                   quantity: quantity,
                   quantity_remaining: BigDecimal.new(0))

      true
    end
  end
end