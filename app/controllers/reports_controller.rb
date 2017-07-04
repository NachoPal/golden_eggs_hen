class ReportsController < ApplicationController

  def generate

    @transactions = []

    Transactionn.all.each do |transaction|
      @transactions << {name: transaction.market.name,
                        open: !transaction.sells.present?,
                        quantity: transaction.buys.first.quantity,
                        buy: transaction.buys.first.limit_price,
                        sell: transaction.sells.present? ? transaction.sells.first.limit_price : nil,
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
