# Copyright 2015-2017, Instacart

module Amountable
  class Amount
    include ActiveModel::Model

    class_attribute :columns
    self.columns = []

    def self.column(name, sql_type = nil, default = nil, null = true)
      type = "ActiveRecord::Type::#{sql_type.to_s.camelize}".constantize.new
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, type, null)
    end

    column :amountable_type, :string, nil, false
    column :amountable_id, :integer, nil, false
    column :value_currency, :string, nil, true
    column :value_cents, :integer, 0, false
    column :name, :string, nil, false

    include Amountable::Operations

    monetize :value_cents, with_model_currency: :value_currency

    validates :name, presence: true
    validates :name, uniqueness: {scope: [:amountable_id, :amountable_type]}

    attr_accessor :persistable

    def amountable
      amountable_type.constantize.find(amountable_id)
    end

    def save
      raise StandardError.new("Can't persist amount to database") if persistable == false
      super
    end

  end
end