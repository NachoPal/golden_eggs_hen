class ReportsController < ApplicationController

  def generate

    orders_buy = Order.where(account_id: params[:id], order_type: 'LIMIT_BUY').
                       order(created_at: :asc)

    @markets = []

    orders_buy.each do |order_buy|
      order_sell = Order.where(account_id: params[:id],
                               order_type: 'LIMIT_SELL',
                               market_id: order_buy.market_id).first

      quantity = order_buy.quantity
      benefit = order_buy.quantity * (order_sell.limit_price - order_buy.limit_price).round(8)
      percentage = ((order_sell.limit_price * 100) / order_buy.limit_price) - 100

      @markets << {name: order_buy.market.name,
                   open: order_sell.open,
                   quantity: quantity,
                   buy: order_buy.limit_price,
                   sell: order_sell.limit_price,
                   benefit: order_sell.open ? nil : benefit,
                   percentage: order_sell.open ? nil : percentage}
    end

    @title = 'REPORT'

    respond_to do |format|
      format.pdf do
        render pdf: @title, template: 'reports/generate.slim'
      end
    end
  end
end
