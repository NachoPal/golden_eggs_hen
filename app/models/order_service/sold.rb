module OrderService
  class Sold

    def fire!(order, market_name)
      price_history = Bittrex.client.get("public/getmarkethistory?market=#{market_name}")

      sold = sold_in_the_last_period(price_history, order)

      order.update(open: false) if sold

      sold
    end

    def sold_in_the_last_period(price_history, order)

      price_history.each do |transaction|

        time = "#{transaction['TimeStamp'].split('.').first}+00:00"

        if DateTime.rfc3339(time) > order.updated_at.to_datetime
          return true if transaction['Price'] >= order.limit_price
        else
          return false
        end
      end
      false
    end
  end
end