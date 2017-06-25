module Order
  class SetLostLimit

    def fire!(order)
      calculate_willing_lost(order)
    end

    private

    def calculate_willing_lost(order)

    end
  end
end