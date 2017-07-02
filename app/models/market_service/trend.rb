module MarketService
  class Trend

    def fire!(market_name)
      history  = Bittrex.client.get("public/getmarkethistory?market=#{market_name}")

      if history.present?

        times = history.map{|x| "#{ x['TimeStamp'].split('.').first}+00:00" }

        period_in_min = ((DateTime.rfc3339(times.first) - DateTime.rfc3339(times.last))*24*60).to_i

        prices = history.map{ |x| x['Price'] }
        spread = (((prices.max - prices.min).abs) * 100) / prices.first
        growth = ((prices.last * 100) / prices.first) - 100

        { info: true, period: period_in_min, growth: growth, spread: spread }
      else
        { info: false, period: nil, growth: nil, spread: nil }
      end
    end
  end
end