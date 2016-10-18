# Amountable

[![Build Status](https://travis-ci.org/instacart/amountable.svg?branch=master)](https://travis-ci.org/instacart/amountable)
[![Gem Version](https://badge.fury.io/rb/amountable.svg)](https://badge.fury.io/rb/amountable)

This gem helps you integrate Money fields into your ActiveRecord models without having to add new columns each time.

It also helps manage and sum various components of your models to keep amount definitions consistent across your application.

## Installation

Add

```ruby
gem 'amountable', github: 'instacart/amountable'
```

to your `Gemfile`. Then run

```shell
bundle
```

and

```shell
rake amountable:install:migrations
```

and finally

```shell
rake db:migrate
```

## Usage

Setup your model

```ruby
class Order < ActiveRecord::Base
  act_as_amountable
  amount :subtotal, sets: [:total]
  amount :delivery_fee, sets: [:total, :fees]
  amount :bags_fee, sets: [:total, :fees]
  amount :sales_tax, sets: [:total, :taxes]
  amount :local_tax, sets: [:total, :taxes]
end
```

`act_as_amountable` can take the `storage` option:

```
  act_as_amountable storage: :table
```

where `storage` can be either `:table`, the `amounts` table will be used to store amounts, or `:jsonb`, a JSONB field will be used on the amountable object to store amounts are json. If you use the JSONB format, you can specify the name of the column with the `column` option. The default value for the `storage` option is `:table`.

then create it

```ruby
order = Order.create(
  subtotal: Money.new(123),
  delivery_fee: Money.new(100),
  bags_fee: Money.new(10),
  sales_tax: Money.new(56)
  )
order.subtotal
# => #<Money fractional:123 currency:USD>
order.total
# => #<Money fractional:289 currency:USD>
order.fees
# => #<Money fractional:110 currency:USD>
order.taxes
# => #<Money fractional:56 currency:USD>
```

## Implementation

When you run the migration, an `amounts` table will be created with a polymorphic relationship to an `amountable`, which in the above example would be your orders.

When the an order is created with some amounts, the associated `Amount` objects are persisted.

`Amount` objects are persisted in bulk, so there are no N + 1 queries. If an amount is zero, no `Amount` model is created.

If you choose the JSONB storage option, the `amounts` table will not be used. Instead a JSONB column on the target model will be used.
