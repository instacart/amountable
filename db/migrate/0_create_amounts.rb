# Copyright 2015-2016, Instacart

class CreateAmounts < ActiveRecord::Migration
  def change
    create_table :amounts do |t|
      t.integer :amountable_id, null: false
      t.string :amountable_type, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_monetize :amounts, :value

    add_index :amounts, [:amountable_id, :amountable_type]

    ActiveRecord::Base.connection.execute("CLUSTER amounts USING index_amounts_on_amountable_id_and_amountable_type") if is_pg?
  end

  def is_pg?
    ActiveRecord::Base.connection.instance_values["config"][:adapter].include?('postgresql')
  end
end
