# Copyright 2015-2017, Instacart

module Amountable
  module JsonbMethods
    extend ActiveSupport::Autoload

    def amounts
      @_amounts ||= attribute(amounts_column_name).to_h['amounts'].to_h.map do |name, amount|
        Amount.new(name: name, value_cents: amount['cents'], value_currency: amount['currency'], persistable: false, amountable: self)
      end.to_set
    end

    def set_amount(name, value)
      value = value.to_money
      initialize_column
      amounts_json = attribute(amounts_column_name)
      amounts_json['amounts'] ||= {}
      if value.zero?
        amounts_json['amounts'].delete(name.to_s)
      else
        amounts_json['amounts'][name.to_s] = {'cents' => value.fractional, 'currency' => value.currency.iso_code}
      end
      set_json(amounts_json)
      @_amounts = nil
      @amounts_by_name = nil
      refresh_sets
      value
    end

    def refresh_sets
      initialize_column
      amounts_json = attribute(amounts_column_name)
      amounts_json['sets'] = {}
      amount_sets.each do |name, amount_names|
        sum = find_amounts(amount_names).sum(Money.zero, &:value)
        next if sum.zero?
        amounts_json['sets'][name.to_s] = {'cents' => sum.fractional, 'currency' => sum.currency.iso_code}
      end
      set_json(amounts_json)
    end

    def get_set(name)
      value = attribute(amounts_column_name).to_h['sets'].to_h[name.to_s].to_h
      Money.new(value['cents'].to_i, value['currency'])
    end

    def set_json(json)
      send("#{amounts_column_name}=", json)
    end

    def initialize_column
      send("#{amounts_column_name}=", {}) if attribute(amounts_column_name).nil?
    end
  end
end
