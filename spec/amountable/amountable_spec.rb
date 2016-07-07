# Copyright 2015-2016, Instacart

require 'spec_helper'

describe Amountable do

  it 'should' do
    order = Order.new
    expect { order.save }.not_to change { Amount.count }
    %i(sub_total taxes total).each do |name|
      expect(order.send(name)).to eq(Money.zero)
    end
    order.sub_total = Money.new(100)
    expect(order.sub_total).to eq(Money.new(100))
    expect(order.total).to eq(Money.new(100))
    expect(order.all_amounts.size).to eq(1)
    order.all_amounts.first.tap do |amount|
      expect(amount.name).to eq('sub_total')
      expect(amount.value).to eq(Money.new(100))
      expect(amount.new_record?).to be true
      expect { order.save }.to change { Amount.count }.by(1)
      expect(amount.persisted?).to be true
    end
    expect do
      expect(order.update_attributes(sub_total: Money.new(200)))
    end.not_to change { Amount.count }
  end

  describe 'name=' do
    let (:order) { Order.create }

    it 'should not persist Money.zero' do
      expect(order.sub_total = Money.zero).to eq(Money.zero)
      expect { order.save }.not_to change { Amount.count }
    end

    it 'should not persist Money.zero if using ActiveRecord persistence' do
      expect { order.update(sub_total: Money.zero) }.not_to change { Amount.count }
    end

    it 'should work with ActiveRecord#update' do
      expect { order.update(sub_total: Money.new(1)) }.to change { Amount.count }.by(1)
    end

    it 'should destroy Amount if exist and assigning Money.zero' do
      order.update(sub_total: Money.new(1))
      expect { order.sub_total = Money.zero }.to change { Amount.count }.by(-1)
      expect(order.amounts.empty?).to be true
    end
  end

  it 'should insert amounts in bulk' do
    order = Order.create
    expect do
      order.update(sub_total: Money.new(100), taxes: Money.new(200))
    end.to make_database_queries(count: 1, manipulative: true)
  end
end
