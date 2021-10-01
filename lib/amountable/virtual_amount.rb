# Copyright 2015-2021, Instacart

module Amountable
  class VirtualAmount
    include ActiveModel::Model

    attr_accessor :amountable, :value_cents, :value_currency, :name, :persistable

    include Amountable::Operations

    validates :name, presence: true

    def value
      Money.new(value_cents, value_currency)
    end

    def value=(val)
      self.value_cents = value.fractional
      self.value_currency = value.currency.iso_code
    end

    def new_record?
      true
    end

    def persisted?
      false
    end

    def save
      raise StandardError.new("Can't persist amount to database") if persistable == false
      super
    end
  end
end