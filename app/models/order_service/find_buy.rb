module OrderService
  class FindBuy

    def fire!(wallet)
      currency = wallet.currency.name
      market_name = "#{BASE_MARKET}-#{currency}"
      market = Market.where(name: market_name).first

      #Rails.logger.info "#{market_name}"
      #TODO: Proper Account
      Buy.joins(:transactionn).where(transactionns: {account_id: 1, market_id: market.id}).last
    end
  end
end
