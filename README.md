# Amountable

This gem helps you integrate Money fields into your ActiveRecord models without having to add new column each time.

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
  include Amountable
  amount :subtotal, sets: [:total]
  amount :delivery_fee, sets: [:total, :fees]
  amount :bags_fee, sets: [:total, :fees]
  amount :sales_tax, sets: [:total, :taxes]
  amount :local_tax, sets: [:total, :taxes]
end
```

then create it

```ruby
order = Order.create(subtotal: Money.new(123), delivery_fee: Money.new(100), bags_fee: Money.new(10), sales_tax: Money.new(56))
order.subtotal # #<Money fractional:123 currency:USD>
order.total # #<Money fractional:289 currency:USD>
order.fees # #<Money fractional:110 currency:USD>
order.taxes # #<Money fractional:56 currency:USD>
```
