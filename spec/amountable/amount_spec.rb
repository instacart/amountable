require 'spec_helper'

describe Amount do

  it 'should validate name presence' do
    Amount.new.tap do |amount|
      expect(amount.valid?).to be false
      expect(amount.errors[:name]).not_to be nil
    end
  end

  it 'should validate name uniqueness' do
    Amount.new(name: 'test', amountable_id: 1, amountable_type: 'Amountable').tap do |amount|
      expect(amount.valid?).to be true
      amount.save
      Amount.new(name: 'test', amountable_id: 2, amountable_type: 'Amountable').tap do |other_amount|
        expect(other_amount.valid?).to be true
        other_amount.amountable_id = amount.amountable_id
        expect(other_amount.valid?).to be false
        expect(amount.errors[:name]).not_to be nil
      end
    end
  end

  it 'should have operations' do
    expect(Amount.new(value: Money.new(1)) + Amount.new(value: Money.new(2))).to eq(Money.new(3))
    expect(Amount.new(value: Money.new(1)) + 0.02).to eq(Money.new(3))
    expect(Amount.new(value: Money.new(2)) - Amount.new(value: Money.new(1))).to eq(Money.new(1))
    expect(Amount.new(value: Money.new(2)) - 0.01).to eq(Money.new(1))
    expect(Amount.new(value: Money.new(2)) * 3).to eq(Money.new(6))
    expect(Amount.new(value: Money.new(6)) / 3).to eq(Money.new(2))
    expect(Amount.new(value: Money.new(2)).to_money).to eq(Money.new(2))
  end

end
