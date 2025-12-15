# Copyright 2015-2021, Instacart

ENV['RAILS_ENV'] = 'test'
require 'rails'
require 'money-rails'
require 'active_record'
require 'activerecord-import'
require 'amountable'
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
MoneyRails::Hooks.init
require 'amountable/amount'
require 'database_cleaner'
require 'db-query-matchers'

Money.locale_backend = :i18n
Money.default_currency = "USD"

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
