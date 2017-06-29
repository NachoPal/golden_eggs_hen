class ReportsController < ApplicationController

  def generate

    @transactions = []

    Transaction.all.each do |transaction|
      @transactions << {name: transaction.market.name,
                        open: !transaction.sell_order.present?,
                        quantity: transaction.quantity,
                        buy: transaction.buy_order.limit_price,
                        sell: transaction.sell_order.present? ? transaction.sell_order.limit_price : nil,
                        benefit: transaction.benefit,
                        percentage: transaction.percentage}
    end


    @title = 'REPORT'

    respond_to do |format|
      format.pdf do
        render pdf: @title, template: 'reports/generate.slim'
      end
    end
  end
end
