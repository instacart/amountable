# Copyright 2015-2016, Instacart

require 'spec_helper'

describe Amountable::NilAmount do

  it 'should return 0' do
    expect(subject.value).to eq(Money.zero)
  end

  it 'should have nil amountable' do
    expect(subject.amountable).to be nil
  end

  it 'should have operations' do
    expect(subject + Amountable::Amount.new(value: Money.new(2))).to eq(Money.new(2))
    expect(subject + 0.02).to eq(Money.new(2))
    expect(subject - Amountable::Amount.new(value: Money.new(1))).to eq(Money.new(-1))
    expect(subject - 0.01).to eq(Money.new(-1))
    expect(subject * 3).to eq(Money.zero)
    expect(subject / 3).to eq(Money.zero)
    expect(subject.to_money).to eq(Money.zero)
  end

end
