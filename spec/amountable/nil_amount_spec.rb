# Copyright 2015, Instacart

require 'spec_helper'

describe NilAmount do

  it 'should return 0' do
    expect(NilAmount.new.value).to eq(Money.zero)
  end

  it 'should have nil amountable' do
    expect(NilAmount.new.amountable).to be nil
  end

  it 'should have operations' do
    expect(NilAmount.new + Amount.new(value: Money.new(2))).to eq(Money.new(2))
    expect(NilAmount.new + 0.02).to eq(Money.new(2))
    expect(NilAmount.new - Amount.new(value: Money.new(1))).to eq(Money.new(-1))
    expect(NilAmount.new - 0.01).to eq(Money.new(-1))
    expect(NilAmount.new * 3).to eq(Money.zero)
    expect(NilAmount.new / 3).to eq(Money.zero)
    expect(NilAmount.new.to_money).to eq(Money.zero)
  end

end
