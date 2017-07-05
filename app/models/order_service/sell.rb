module OrderService
  class Sell
    def fire!(buy_record, wallet, market, future_order)

      if !future_order
        bid_orders = check_bid_orders(market.name)

        bid_orders.each do |bid_order|
          if bid_order['Quantity'] >= wallet.balance

            lose_threshold_price = ((100 - THRESHOLD_OF_LOST) * buy_record.limit_price) / 100

            if bid_order['Rate'] >= lose_threshold_price
              sell(buy_record, bid_order['Rate'], wallet.balance, true)
              return true
            else
              OrderService::Cancel.new.fire!(buy_record)
              sell(buy_record, lose_threshold_price, wallet.balance, false)
              return false
            end
          else
            next
          end
        end
        false
      else
        rate = ((100 + THRESHOLD_OF_GAIN) * buy_record.limit_price) / 100
        sell(buy_record, rate, wallet.balance, false)
        return false
      end
    end

    private

    def check_bid_orders(market)
      Bittrex.client.get("public/getorderbook?market=#{market}&type=buy")
    end

    def sell(buy_record, price, quantity, success)
      sell_order = Orderr::Sell.new(limit_price: price,
                                    quantity: quantity,
                                    quantity_remaining: BigDecimal.new(0),
                                    open: !success)


      transaction = buy_record.transactionn

      transaction.orderrs << sell_order
    end
  end
end