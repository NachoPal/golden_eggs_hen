module OrderService
  class Cancel

    def fire!(order)
      sell_order = order.transactionn.sells

      if sell_order.present?
        sell_order.first.destroy
      end
    end
  end
end