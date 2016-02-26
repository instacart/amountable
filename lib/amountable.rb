# Copyright 2015, Instacart

module Amountable
  extend ActiveSupport::Autoload
  autoload :Amount
  autoload :VERSION

  class InvalidAmountName < StandardError; end

  def self.included(base)

    base.extend Amountable::ClassMethods

    base.class_eval do
      has_many :amounts, as: :amountable, dependent: :destroy, autosave: false
      validate :validate_amount_names
      class_attribute :amount_names
      class_attribute :amount_sets
      self.amount_sets = Hash.new { |h, k| h[k] = Set.new }
      self.amount_names = Set.new

      def all_amounts
        @all_amounts ||= amounts.to_set
      end

      def find_amount(name)
        (@amounts_by_name ||= {})[name.to_sym] ||= all_amounts.find { |am| am.name == name.to_s }
      end

      def find_amounts(names)
        all_amounts.select { |am| names.include?(am.name.to_sym) }
      end

      def validate_amount_names
        amounts.each do |amount|
          errors.add(:amounts, "#{amount.name} is not an allowed amount name.") unless self.class.allowed_amount_name?(amount.name)
        end
      end

      def serializable_hash(opts = nil)
        opts ||= {}
        super(opts).tap do |base|
          unless opts[:except].to_a.include?(:amounts)
            amounts_json = (self.class.amount_names + self.class.amount_sets.keys).inject({}) do |mem, name|
              mem.merge!(name.to_s => send(name).to_f) unless opts[:except].to_a.include?(name.to_sym)
              mem
            end
            base.merge!(amounts_json)
          end
        end
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

    end
  end

  module ClassMethods

    def amount_set(set_name, component)
      self.amount_sets[set_name.to_sym] << component.to_sym

      define_method set_name do
        find_amounts(self.amount_sets[set_name.to_sym]).sum(Money.zero, &:value)
      end
    end

    def amount(name, options = {})
      (self.amount_names ||= Set.new) << name

      define_method name do
        (find_amount(name) || NilAmount.new).value
      end

      define_method "#{name}=" do |value|
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
        value.to_money
      end

      Array(options[:summable] || options[:summables] || options[:set] || options[:sets] || options[:amount_set] || options[:amount_sets]).each do |set|
        amount_set(set, name)
      end
    end

    def allowed_amount_name?(name)
      self.amount_names.include?(name.to_sym)
    end

  end
end
