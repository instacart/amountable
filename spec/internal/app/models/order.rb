# Copyright 2015-2021, Instacart

class Order < ActiveRecord::Base

  include Amountable
  act_as_amountable
  amount :sub_total, sets: [:total]
  amount :taxes, sets: [:total]

end
