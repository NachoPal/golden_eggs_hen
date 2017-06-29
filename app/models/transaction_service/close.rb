module TransactionService
  class Close

    def fire!(buy_record, sell_record)
      result = calculate_statistics(buy_record, sell_record)

      Transaction.where(buy_order_id: buy_record.id, sell_order_id: nil).last.
                  update(sell_order_id: sell_record.id, benefit: result[:benefit],
                         percentage: result[:percentage])
    end

    def calculate_statistics(buy_record, sell_record)
     buy_price = buy_record.limit_price
     sell_price = sell_record.limit_price
     quantity = buy_record.quantity

     benefit = BigDecimal.new(quantity * (sell_price - buy_price)).floor(8)
     percentage = BigDecimal.new((((sell_price * 100) / buy_price) - 100)).floor(2)

     {benefit: benefit, percentage: percentage}
    end
  end
end