module OrderService
  class Cancel

    def fire!(order)
      #========== LIVE ================
      #Bittrex.client.get("market/cancel?uuid=#{order.uuid}")
      #================================

      order.destroy
    end
  end
end