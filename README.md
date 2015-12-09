# Amountable

This gem helps you integrate Money fields into your ActiveRecord models without having to add new column each time.

It also helps manage and sum various components of your models to keep amount definitions consistent across your application.

## Installation

Add
```gem 'amountable', github: 'instacart/amountable'```
to your `Gemfile`. Then run
```bundle```
and
```rake amountable:install:migrations```
and finally
```rake db:migrate```
