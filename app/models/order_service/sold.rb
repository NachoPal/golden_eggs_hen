module OrderService
  class Sold

    def fire!(order)
      market_name = order.market.name
      current_price = Bittrex.client.get("public/getmarketsummary?market=#{market_name}").first['Last']

      Rails.logger.info "Order: #{order}"
      Rails.logger.info "Current price: #{current_price}"

      if current_price <= order.limit_price

        # filename = Rails.root + 'history.pdf'
        # Prawn::Document.generate('history.pdf', :template => filename) do
        #   text "\nSELL ----------- #{market_name} ----------------"
        # end



        wallets = WalletService::Retrieve.new.fire!

        btc_wallet = wallets.joins(:currency).where(currencies: {name: 'BTC'}).first
        current_balance = btc_wallet.balance
        current_available = btc_wallet.available
        btc_wallet.update(balance: current_balance + order.limit_price,
                          available: current_available + order.limit_price)

        sold_wallet = wallets.joins(:currency).
                              where(currencies: {name: order.market.name.split('-').last}).first


        # Prawn::Document.generate('history.pdf', :template => filename) do
        #   text "Rate: #{order.limit_price}"
        #   text "Quantity: #{order.quantity}"
        # end


        sold_wallet.destroy
        order.update(open: false)
      end
    end
  end
end