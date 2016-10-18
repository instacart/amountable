# Copyright 2015-2016, Instacart

module Amountable
  class Amount < ActiveRecord::Base

    include Amountable::Operations

    belongs_to :amountable, polymorphic: true

    monetize :value_cents

    validates :name, presence: true
    validates :name, uniqueness: {scope: [:amountable_id, :amountable_type]}

    attr_accessor :persistable

    def save
      raise StandardError.new("Can't persist amount to database") if persistable == false
      super
    end

  end
end