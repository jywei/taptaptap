# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150226104235) do

  create_table "demand_group_rates", force: true do |t|
    t.integer  "demand_source_rate_id"
    t.string   "group",                 limit: 4
    t.decimal  "rate",                             precision: 8, scale: 6
    t.string   "direction",             limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "demand_group_rates", ["demand_source_rate_id"], name: "index_demand_group_rates_on_demand_source_rate_id", using: :btree

  create_table "demand_source_rates", force: true do |t|
    t.string   "auth_token", limit: 32
    t.string   "source",     limit: 5
    t.decimal  "rate",                  precision: 8,  scale: 6
    t.string   "direction",  limit: 10
    t.boolean  "all_groups"
    t.decimal  "max_sum",               precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_category_rates", force: true do |t|
    t.integer  "payment_group_rate_id"
    t.string   "source",                limit: 5
    t.string   "category_group",        limit: 4
    t.string   "category",              limit: 4
    t.decimal  "rate",                             precision: 8, scale: 6
    t.string   "direction",             limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_group_rates", force: true do |t|
    t.integer  "payment_rate_id"
    t.string   "source",          limit: 5
    t.string   "category_group",  limit: 4
    t.decimal  "rate",                       precision: 8, scale: 6
    t.boolean  "all_categories"
    t.string   "direction",       limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_rates", force: true do |t|
    t.string   "source",     limit: 5
    t.decimal  "rate",                  precision: 8, scale: 6
    t.boolean  "all_groups"
    t.string   "direction",  limit: 10
    t.string   "string",     limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistic_by_transfered_data", force: true do |t|
    t.string   "source"
    t.string   "category_group"
    t.string   "category",       limit: 4
    t.string   "auth_token",     limit: 32
    t.string   "ip",             limit: 15
    t.date     "for_date"
    t.integer  "amount"
    t.integer  "data_size"
    t.string   "direction"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statistic_by_transfered_data", ["source", "category", "for_date"], name: "index_on_source_category", using: :btree
  add_index "statistic_by_transfered_data", ["source", "for_date"], name: "index_on_source_category_group", using: :btree

end
