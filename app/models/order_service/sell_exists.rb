module OrderService
  class SellExists

    def fire!(buy_order)
      open_sell_order = buy_order.transactionn.sells

      {exists: open_sell_order.present?, order: open_sell_order.first}
    end
  end
end