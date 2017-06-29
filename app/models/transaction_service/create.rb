module TransactionService
  class Create

    def fire!(buy_record)
      Transaction.create(buy_order_id: buy_record.id, quantity: buy_record.quantity)
    end
  end
end