# Copyright 2015-2016, Instacart

module Amountable
  module JsonbMethods
    extend ActiveSupport::Autoload

    def amounts
      @_amounts ||= attributes[amounts_column_name].to_h['amounts'].to_h.map do |name, amount|
        Amount.new(name: name, value_cents: amount['cents'], value_currency: amount['value_currency'], persistable: false)
      end.to_set
    end

    def set_amount(name, value)
      value = value.to_money
      assign_attributes(amounts_column_name => {}) if attributes[amounts_column_name].nil?
      attributes[amounts_column_name]['amounts'] ||= {}
      attributes[amounts_column_name]['amounts'][name.to_s] = {'cents' => value.fractional, 'currency' => value.currency.iso_code}
      @_amounts = nil
      @amounts_by_name = nil
      refresh_sets
      value
    end

    def refresh_sets
      assign_attributes(amounts_column_name => {}) if attributes[amounts_column_name].nil?
      attributes[amounts_column_name]['sets'] = {}
      amount_sets.each do |name, amount_names|
        sum = find_amounts(amount_names).sum(Money.zero, &:value)
        attributes[amounts_column_name]['sets'][name.to_s] = {'cents' => sum.fractional, 'currency' => sum.currency.iso_code}
      end
    end

    def get_set(name)
      value = attributes[amounts_column_name].to_h['sets'].to_h[name.to_s].to_h
      Money.new(value['cents'].to_i, value['currency'] || 'USD')
    end

  end
end
