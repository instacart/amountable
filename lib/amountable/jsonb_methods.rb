# Copyright 2015-2016, Instacart

module Amountable
  module JsonbMethods
    extend ActiveSupport::Autoload

    def amounts
      @_amounts ||= (attributes['amounts']['amounts'] || {}).map do |name, amount|
        Amount.new(name: name, value_cents: amount['cents'], value_currency: amount['value_currency'], persistable: false)
      end.to_set
    end

    def set_amount(name, value)
      value = value.to_money
      attributes['amounts']['amounts'] ||= {}
      attributes['amounts']['amounts'][name.to_s] = {'cents' => value.fractional, 'currency' => value.currency.iso_code}
      @_amounts = nil
      @amounts_by_name = nil
      refresh_sets
      value
    end

    def refresh_sets
      attributes['amounts']['sets'] = {}
      self.amount_sets.each do |name, amount_names|
        sum = find_amounts(amount_names).sum(Money.zero, &:value)
        attributes['amounts']['sets'][name.to_s] = {'cents' => sum.fractional, 'currency' => sum.currency.iso_code}
      end
    end

    def get_set(name)
      value = attributes['amounts']['sets'].to_h[name.to_s].to_h
      Money.new(value['cents'].to_i, value['currency'] || 'USD')
    end

  end
end
