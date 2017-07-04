module OrderService
  class FindBuy

    def fire!(market)

      #Rails.logger.info "#{market_name}"
      #TODO: Proper Account
      Orderr::Buy.joins(:transactionn).where(transactionns: {account_id: 1, market_id: market.id}).last
    end
  end
end
