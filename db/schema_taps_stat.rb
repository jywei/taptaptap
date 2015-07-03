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

ActiveRecord::Schema.define(version: 20150122220336) do

  create_table "annotations_locations", force: true do |t|
    t.string   "source",            limit: 5
    t.string   "category",          limit: 4
    t.string   "annotation",        limit: 30
    t.string   "country",           limit: 10
    t.string   "state",             limit: 10
    t.string   "metro",             limit: 10
    t.string   "region",            limit: 11
    t.string   "county",            limit: 10
    t.string   "city",              limit: 12
    t.string   "locality",          limit: 12
    t.string   "zipcode",           limit: 9
    t.integer  "count_occurrences",            default: 0
    t.integer  "total_count",                  default: 0
    t.integer  "volume"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations_locations", ["source", "category", "annotation", "city", "country", "county", "locality", "metro", "region", "state", "zipcode"], name: "index_annotations_locations_unique_index", unique: true, using: :btree

  create_table "average_qualities", force: true do |t|
    t.integer  "postings"
    t.float    "fields_quality"
    t.float    "annotations_quality"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source",              limit: 5
    t.date     "for_date"
  end

  create_table "calculate_annotations", force: true do |t|
    t.string   "source",            limit: 5
    t.string   "category",          limit: 5
    t.string   "annotation"
    t.integer  "count_occurrences"
    t.integer  "total_count"
    t.integer  "weight",                      default: 1
    t.string   "samle_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "calculate_annotations", ["source", "category", "annotation"], name: "index_on_source_category", unique: true, using: :btree

  create_table "latency_hourly_statistics", force: true do |t|
    t.string   "source"
    t.float    "latency"
    t.datetime "for_hour"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "latency_hourly_statistics", ["source", "for_hour"], name: "index_on_source_latency", unique: true, using: :btree

  create_table "statistic_by_annotations_qualities", force: true do |t|
    t.string   "source",             limit: 5
    t.string   "transit_ip_address"
    t.date     "for_date"
    t.integer  "quality",            limit: 3
    t.integer  "quantity",           limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statistic_by_annotations_qualities", ["source", "for_date", "quality"], name: "index_on_source_quality", unique: true, using: :btree

  create_table "statistic_by_categories", force: true do |t|
    t.string   "category",       limit: 5
    t.date     "for_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category_group", limit: 4
    t.string   "ip_address",     limit: 15
    t.integer  "count"
  end

  create_table "statistic_by_dates", force: true do |t|
    t.string   "date",       limit: 10
    t.date     "for_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address", limit: 15
    t.integer  "count"
  end

  create_table "statistic_by_fields_qualities", force: true do |t|
    t.string   "source",             limit: 5
    t.string   "transit_ip_address"
    t.date     "for_date"
    t.integer  "quality",            limit: 3
    t.integer  "quantity",           limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statistic_by_fields_qualities", ["source", "for_date", "quality"], name: "index_on_source_quality", unique: true, using: :btree

  create_table "statistic_by_heartbeats", force: true do |t|
    t.datetime "for_timestamp"
    t.string   "criteria"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistic_by_latencies", force: true do |t|
    t.integer  "posting_id"
    t.string   "source",             limit: 5
    t.integer  "latency"
    t.datetime "posting_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistic_by_metros", force: true do |t|
    t.date    "for_date"
    t.integer "count"
    t.string  "category"
    t.string  "metro"
  end

  create_table "statistic_by_sources", force: true do |t|
    t.string   "source",     limit: 5
    t.integer  "utc_hour"
    t.integer  "count"
    t.date     "for_date"
    t.boolean  "deleted",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistic_by_updates", force: true do |t|
    t.date    "for_date"
    t.string  "source"
    t.string  "category"
    t.integer "count"
  end

  create_table "statistic_by_utc_hours", force: true do |t|
    t.integer  "utc_hour",   limit: 2
    t.date     "for_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address", limit: 15
    t.integer  "count"
  end

  create_table "statistic_by_volumes", force: true do |t|
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
