module OrderService
  class FindBuy

    def fire!(market)
      Orderr::Buy.joins(:transactionn).where(transactionns: {account_id: 1, market_id: market.id}).last
    end
  end
end
