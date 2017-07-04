module TransactionService
  class Close

    def fire!(transaction)
      buy_record = transaction.buys.first
      sell_record = transaction.sells.first

      result = calculate_statistics(buy_record, sell_record)

      transaction.update(benefit: result[:benefit], percentage: result[:percentage])
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