module OrderService
  class Buy

    #TODO: I have to check if it's worth it to buy to the success ask order price
    def fire!(market)
      ask_orders = check_ask_orders(market.name)

      ask_orders.each do |ask_order|
        quantity = BTC_QUANTITY_TO_BUY / ask_order['Rate']

        if quantity <= ask_order['Quantity']
          #Here is where I should add an IF to check the final order price
          #If is not worth it I return {success: false, order: nil}
          success = buy(market, ask_order['Rate'], quantity)

          # filename = Rails.root + 'history.pdf'
          # Prawn::Document.generate('history.pdf', :template => filename) do
          #   text "\nBUY ----------- #{market.name} ----------------"
          # end

          #============ Rellenar Walllet (solo virtual)==================
          currency = Currency.where(name: market.name.split('-').last).first

          WalletService::Create.new.fire!(currency, quantity, ask_order['Rate'])


          # Prawn::Document.generate('history.pdf', :template => filename) do
          #   text "Rate: #{ask_order['Rate']}"
          #   text "Quantity: #{quantity*ask_order['Rate']}"
          # end

          #==============================================================

          break if success
        else
          next
        end
      end
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

      transaction = TransactionService::Create.new.fire!(market)

      #TODO: Select proper account

      buy_order = Orderr::Buy.new(limit_price: price,
                          quantity: quantity,
                          quantity_remaining: BigDecimal.new(0),
                          open: false)

      transaction.orderrs << buy_order

      Rails.logger.info "---------- Buy -------------"
      Rails.logger.info "Market: #{market.name}"
      Rails.logger.info "Stored Price: #{market.price}"
      Rails.logger.info "Current Price: #{price}"
      Rails.logger.info "----------------------------"

      true
    end
  end
end