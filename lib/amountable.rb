# Copyright 2015-2016, Instacart

module Amountable
  extend ActiveSupport::Autoload
  autoload :Operations
  autoload :Amount
  autoload :NilAmount
  autoload :VERSION
  autoload :TableMethods
  autoload :JsonbMethods

  class InvalidAmountName < StandardError; end
  class MissingColumn < StandardError; end

  ALLOWED_STORAGE = %i(table json).freeze

  def self.included(base)
    base.extend Amountable::ClassMethods
  end

  module InstanceMethods

    def all_amounts
      @all_amounts ||= amounts.to_set
    end

    def find_amount(name)
      (@amounts_by_name ||= {})[name.to_sym] ||= amounts.to_set.find { |am| am.name == name.to_s }
    end

    def find_amounts(names)
      amounts.to_set.select { |am| names.include?(am.name.to_sym) }
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
  end

  module ClassMethods

    # Possible storage values: [:table, :jsonb]
    def act_as_amountable(options = {})
      class_attribute :amount_names
      class_attribute :amount_sets
      class_attribute :amounts_column_name
      self.amount_sets = Hash.new { |h, k| h[k] = Set.new }
      self.amount_names = Set.new
      self.amounts_column_name = 'amounts'
      case (options[:storage] || :table).to_sym
      when :table
        has_many :amounts, class_name: 'Amountable::Amount', as: :amountable, dependent: :destroy, autosave: false
        include Amountable::TableMethods
      when :jsonb
        self.amounts_column_name = options[:column].to_s if options[:column]
        raise MissingColumn.new("You need an amounts jsonb field on the #{self.table_name} table.") unless column_names.include?(self.amounts_column_name)
        include Amountable::JsonbMethods
      else
        raise ArgumentError.new("Please specify a storage: #{ALLOWED_STORAGE}")
      end
      validate :validate_amount_names
      include Amountable::InstanceMethods
    end

    def amount_set(set_name, component)
      self.amount_sets[set_name.to_sym] << component.to_sym

      define_method set_name do
        get_set(set_name)
      end
    end

    def amount(name, options = {})
      (self.amount_names ||= Set.new) << name

      define_method name do
        (find_amount(name) || Amountable::NilAmount.new).value
      end

      define_method "#{name}=" do |value|
        set_amount(name, value)
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

ActiveSupport.on_load(:active_record) do
  include Amountable
end
