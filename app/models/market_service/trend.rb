module MarketService
  class Trend

    def fire!(market_name)
      history  = Bittrex.client.get("public/getmarkethistory?market=#{market_name}")

      if history.present?
        size = history.count

        first_price = 0

        history.each_with_index do |order, i|
          first_price = order['Price'] if i == 0

          order_time = DateTime.rfc3339("#{ order['TimeStamp'].split('.').first}+08:00")
          current_time = DateTime.now - 8.hour

          if order_time > current_time - PERIOD_GROWTH.minute
            if i == size - 1
              last_price = order['Price']
              return { info: true, growth: ((first_price * 100) / last_price) - 100 }
            else
              next
            end
          else
            last_price = order['Price']
            return { info: true, growth: ((first_price * 100) / last_price) - 100 }
          end
        end
      else
        { info: false, growth: nil }
      end
    end
  end
end