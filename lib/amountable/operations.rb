# Copyright 2015-2016, Instacart

module Amountable
  module Operations

    def +(other_value)
      value + other_value.to_money
    end

    def -(other_value)
      value - other_value.to_money
    end

    def *(multiplier)
      value * multiplier
    end

    def /(divisor)
      value / divisor
    end

    def to_money
      value
    end

  end
end