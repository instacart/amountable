class Order < ActiveRecord::Base

  include Amountable

  amount :sub_total, sets: [:total]
  amount :taxes, sets: [:total]

end
