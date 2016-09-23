# Copyright 2015-2016, Instacart

module Amountable
  module TableMethods
    extend ActiveSupport::Autoload

    def set_amount(name, value)
      amount = find_amount(name) || amounts.build(name: name)
      amount.value = value.to_money
      if value.zero?
        amounts.delete(amount)
        all_amounts.delete(amount)
        @amounts_by_name.delete(name)
        amount.destroy if amount.persisted?
      else
        all_amounts << amount if amount.new_record?
        (@amounts_by_name ||= {})[name.to_sym] = amount
      end
      amount.value
    end

    def save(args = {})
      ActiveRecord::Base.transaction do
        save_amounts if super(args)
      end
    end

    def save!(args = {})
      ActiveRecord::Base.transaction do
        save_amounts! if super(args)
      end
    end

    def save_amounts(bang: false)
      amounts_to_insert = []
      amounts.each do |amount|
        if amount.new_record?
          amount.amountable_id = self.id
          amounts_to_insert << amount
        else
          bang ? amount.save! : amount.save
        end
      end
      Amount.import(amounts_to_insert, timestamps: true, validate: false)
      amounts_to_insert.each do |amount|
        amount.instance_variable_set(:@new_record, false)
      end
      true
    end

    def save_amounts!; save_amounts(bang: true); end

    def get_set(name)
      find_amounts(self.amount_sets[name.to_sym]).sum(Money.zero, &:value)
    end

  end
end
