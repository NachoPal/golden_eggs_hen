module OrderService
  class Sold

    def fire!(order, market_name)
      price_history = Bittrex.client.get("public/getmarkethistory?market=#{market_name}")

      sold = sold_in_the_last_period(price_history, order)

      order.update(open: false) if sold

      sold
    end

    def sold_in_the_last_period(price_history, order)

      buy_order = order.transactionn.buys.first

      price_history.each do |transaction|

        time = "#{transaction['TimeStamp'].split('.').first}+00:00"

        if DateTime.rfc3339(time) > order.updated_at.to_datetime
          if buy_order.limit_price < order.limit_price
            return true if transaction['Price'] >= order.limit_price
          elsif buy_order.limit_price > order.limit_price
            return true if transaction['Price'] <= order.limit_price
          end
        else
          return false
        end
      end
      false
    end
  end
end