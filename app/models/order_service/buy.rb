module OrderService
  class Buy

    def fire!(market)
      ask_orders = check_ask_orders(market.name)

      ask_orders.each do |ask_order|
        quantity = BTC_QUANTITY_TO_BUY / ask_order['Rate']

        if quantity <= ask_order['Quantity']

          success = buy(market, ask_order['Rate'], quantity)

          currency = Currency.where(name: market.name.split('-').last).first

          WalletService::Create.new.fire!(currency, quantity, ask_order['Rate'])

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
      transaction = TransactionService::Create.new.fire!(market)

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