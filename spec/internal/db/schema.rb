# Copyright 2015-2016, Instacart

ActiveRecord::Schema.define do

  create_table "amounts", force: :cascade do |t|
    t.integer  "amountable_id",                   null: false
    t.string   "amountable_type",                 null: false
    t.datetime "created_at"
    t.string   "name",                            null: false
    t.datetime "updated_at"
    t.integer  "value_cents",     default: 0,     null: false
    t.string   "value_currency",  default: "USD", null: false
  end
  add_index "amounts", ["amountable_id", "amountable_type"], name: "index_amounts_on_amountable_id_and_amountable_type", using: :btree

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
