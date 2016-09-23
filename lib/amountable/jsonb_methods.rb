# Copyright 2015-2016, Instacart

module Amountable
  module JsonbMethods
    extend ActiveSupport::Autoload

    def amounts
      @_amounts ||= (attributes['amounts']['amounts'] || {}).map do |name, amount|
        Amount.new(name: name, value_cents: amount['value_cents'], value_currency: amount['value_currency'], persistable: false)
      end.to_set
    end

    def set_amount(name, value)
      value = value.to_money
      attributes['amounts']['amounts'] ||= {}
      attributes['amounts']['amounts'][name.to_s] = {'value_cents' => value.fractional, 'value_currency' => value.currency.iso_code}
      @_amounts = nil
      @amounts_by_name = nil
      value
    end

  end
end
