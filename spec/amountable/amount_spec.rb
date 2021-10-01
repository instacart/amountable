# Copyright 2015-2021, Instacart

require 'spec_helper'

describe Amountable::Amount do

  it 'should validate name presence' do
    subject.tap do |amount|
      expect(amount.valid?).to be false
      expect(amount.errors[:name]).not_to be nil
    end
  end

  it 'should validate name uniqueness' do
    Amountable::Amount.new(name: 'test', amountable_id: 1, amountable_type: 'Amountable').tap do |amount|
      expect(amount.valid?).to be true
      amount.save
      Amountable::Amount.new(name: 'test', amountable_id: 2, amountable_type: 'Amountable').tap do |other_amount|
        expect(other_amount.valid?).to be true
        other_amount.amountable_id = amount.amountable_id
        expect(other_amount.valid?).to be false
        expect(amount.errors[:name]).not_to be nil
      end
    end
  end

  it 'should have operations' do
    expect(Amountable::Amount.new(value: Money.new(1)) + Amountable::Amount.new(value: Money.new(2))).to eq(Money.new(3))
    expect(Amountable::Amount.new(value: Money.new(1)) + 0.02).to eq(Money.new(3))
    expect(Amountable::Amount.new(value: Money.new(2)) - Amountable::Amount.new(value: Money.new(1))).to eq(Money.new(1))
    expect(Amountable::Amount.new(value: Money.new(2)) - 0.01).to eq(Money.new(1))
    expect(Amountable::Amount.new(value: Money.new(2)) * 3).to eq(Money.new(6))
    expect(Amountable::Amount.new(value: Money.new(6)) / 3).to eq(Money.new(2))
    expect(Amountable::Amount.new(value: Money.new(2)).to_money).to eq(Money.new(2))
  end

  it 'should not save if not persistable' do
    expect { subject.new(persistable: false).save }.to raise_exception(StandardError)
  end

end
