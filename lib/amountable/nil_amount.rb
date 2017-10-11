# Copyright 2015-2017, Instacart

module Amountable
  class NilAmount
    include Amountable::Operations
    def value; Money.zero; end
    def amountable; nil; end
  end
end