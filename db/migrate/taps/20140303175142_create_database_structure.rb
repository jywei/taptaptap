# encoding: UTF-8
class CreateDatabaseStructure < ActiveRecord::Migration
  def up
    create_table "backpage_processes" do |t|
      t.datetime "started_at"
      t.datetime "finished_at"
      t.text     "processed_files"
      t.integer  "postings_added"
      t.integer  "postings_failed"
      t.integer  "postings_total"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "backpage_source_postings" do |t|
      t.integer  "posting_id"
      t.integer  "backpage_source_id"
      t.text     "convert_errors"
      t.text     "original_xml"
      t.text     "json_hash"
      t.string   "unique_hash"
      t.boolean  "converted",          default: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "backpage_source_postings", ["unique_hash"], name: "index_backpage_source_postings_on_unique_hash", using: :btree

    create_table "backpage_sources" do |t|
      t.string   "original_filename"
      t.text     "original_xml",       limit: 16777215
      t.datetime "original_timestamp"
      t.datetime "downloaded_at"
      t.datetime "parsed_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "converters" do |t|
      t.boolean  "convert_status"
      t.string   "status"
      t.string   "source"
      t.string   "reject_category"
      t.boolean  "use_reject_category"
      t.string   "accept_category"
      t.boolean  "use_accept_category"
      t.string   "reject_category_group"
      t.boolean  "use_reject_category_group"
      t.string   "accept_category_group"
      t.boolean  "use_accept_category_group"
      t.boolean  "use_geolocation_module"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "convert_state"
      t.string   "state"
      t.string   "reject_state"
      t.boolean  "use_reject_state"
      t.string   "accept_state"
      t.boolean  "use_accept_state"
      t.string   "reject_status"
      t.boolean  "use_reject_status"
      t.string   "accept_status"
      t.boolean  "use_accept_status"
      t.boolean  "convert_flagged_status"
      t.string   "flagged_status"
      t.string   "reject_flagged_status"
      t.boolean  "use_reject_flagged_status"
      t.string   "accept_flagged_status"
      t.boolean  "use_accept_flagged_status"
      t.string   "convert_status_values"
      t.string   "convert_state_values"
      t.string   "convert_flagged_status_values"
    end

    create_table "craig_locations" do |t|
      t.string   "lat"
      t.string   "long"
      t.text     "location"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "craig_locations", ["lat"], name: "index_craig_locations_on_lat", using: :btree
    add_index "craig_locations", ["long"], name: "index_craig_locations_on_long", using: :btree

    create_table "current_volume", id: false do |t|
      t.integer "volume"
    end

    create_table "first_volume", id: false do |t|
      t.integer "volume"
    end

    create_table "geo_batches" do |t|
      t.integer "min_id"
      t.integer "max_id"
    end

    create_table "geo_caches" do |t|
      t.string   "formatted_address"
      t.decimal  "lat",               precision: 9, scale: 6
      t.decimal  "long",              precision: 9, scale: 6
      t.integer  "accuracy"
      t.text     "location_hash"
      t.integer  "hits"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "geo_caches", ["formatted_address"], name: "index_geo_caches_on_formatted_address", unique: true, using: :btree
    add_index "geo_caches", ["lat", "long"], name: "index_geo_caches_on_lat_and_long", unique: true, using: :btree

    create_table "html_examples" do |t|
      t.string   "name"
      t.string   "url"
      t.string   "committer"
      t.text     "html",         limit: 2147483647
      t.string   "status"
      t.string   "comment"
      t.boolean  "notification"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "insert_profilers" do |t|
      t.string   "source"
      t.integer  "filter"
      t.integer  "insert"
      t.integer  "render"
      t.integer  "overhead"
      t.integer  "average_per_posting"
      t.integer  "postings_count"
      t.integer  "total_time"
      t.text     "postings"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "auth_token"
      t.integer  "max_posting_time"
      t.integer  "min_posting_time"
    end

    add_index "insert_profilers", ["created_at"], name: "index_insert_profilers_on_created_at", using: :btree

    create_table "last_volume", id: false do |t|
      t.integer "volume"
    end

    create_table "locations" do |t|
      t.string   "code"
      t.string   "full_name"
      t.string   "short_name"
      t.integer  "parent_id"
      t.string   "country"
      t.string   "state"
      t.string   "metro"
      t.string   "region"
      t.string   "county"
      t.string   "city"
      t.string   "locality"
      t.string   "zipcode"
      t.float    "bounds_max_lat"
      t.float    "bounds_max_long"
      t.float    "bounds_min_lat"
      t.float    "bounds_min_long"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "level"
    end

    add_index "locations", ["parent_id"], name: "index_locations_on_parent_id", using: :btree

    create_table "notifications" do |t|
      t.integer  "status",     default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "type"
    end

    create_table "posting_deletes" do |t|
      t.integer  "timestamp"
      t.string   "external_id"
      t.integer  "source"
      t.integer  "posting_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "posting_deletes", ["posting_id"], name: "index_posting_deletes_on_posting_id", using: :btree

    create_table "posting_examples" do |t|
      t.string   "source"
      t.string   "url"
      t.text     "posting"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "source_code"
    end

    create_table "posting_monitors" do |t|
      t.datetime "time_mark"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "hmngs"
      t.integer  "remls"
      t.integer  "ebaym"
      t.integer  "craig"
      t.integer  "bkpge"
    end

    create_table "posting_stats" do |t|
      t.integer  "posting_id"
      t.datetime "located_at"
      t.datetime "anchored_at"
      t.datetime "polled_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "posting_stats", ["posting_id"], name: "index_posting_stats_on_posting_id", using: :btree

    create_table "posting_thresholds" do |t|
      t.integer  "posting_id"
      t.datetime "posting_created_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "posting_validation_infos" do |t|
      t.integer  "posting_id"
      t.boolean  "source",               default: true
      t.boolean  "category",             default: true
      t.boolean  "external_id",          default: true
      t.boolean  "external_url",         default: true
      t.boolean  "heading",              default: true
      t.boolean  "body",                 default: true
      t.boolean  "html",                 default: true
      t.boolean  "expires",              default: true
      t.boolean  "language",             default: true
      t.boolean  "price",                default: true
      t.boolean  "currency",             default: true
      t.boolean  "images",               default: true
      t.boolean  "annotations",          default: true
      t.boolean  "status",               default: true
      t.boolean  "flagged",              default: true
      t.boolean  "deleted",              default: true
      t.boolean  "immortal",             default: true
      t.boolean  "timestamp",            default: true
      t.boolean  "category_group",       default: true
      t.boolean  "country",              default: true
      t.boolean  "state",                default: true
      t.boolean  "metro",                default: true
      t.boolean  "region",               default: true
      t.boolean  "county",               default: true
      t.boolean  "city",                 default: true
      t.boolean  "locality",             default: true
      t.boolean  "zipcode",              default: true
      t.boolean  "lat",                  default: true
      t.boolean  "long",                 default: true
      t.boolean  "accuracy",             default: true
      t.boolean  "min_lat",              default: true
      t.boolean  "max_lat",              default: true
      t.boolean  "min_long",             default: true
      t.boolean  "max_long",             default: true
      t.boolean  "account_id",           default: true
      t.boolean  "posting_state",        default: true
      t.boolean  "flagged_status",       default: true
      t.boolean  "origin_ip_address",    default: true
      t.boolean  "transit_ip_address",   default: true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "original_external_id"
      t.string   "original_source"
      t.string   "auth_token"
      t.string   "ip_address"
      t.boolean  "formatted_address"
    end

    create_table "postings" do |t|
      t.string   "source",             limit: 5
      t.string   "category",           limit: 4
      t.string   "external_id"
      t.string   "external_url",       limit: 512
      t.string   "heading"
      t.text     "body"
      t.text     "html"
      t.integer  "expires"
      t.string   "language"
      t.float    "price"
      t.string   "currency"
      t.text     "images"
      t.text     "annotations"
      t.string   "status",             limit: 10
      t.boolean  "flagged"
      t.boolean  "deleted"
      t.boolean  "immortal"
      t.integer  "timestamp"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "category_group",     limit: 4
      t.string   "country",            limit: 12
      t.string   "state",              limit: 12
      t.string   "metro",              limit: 12
      t.string   "region",             limit: 12
      t.string   "county",             limit: 12
      t.string   "city",               limit: 12
      t.string   "locality",           limit: 12
      t.string   "zipcode",            limit: 12
      t.float    "lat"
      t.float    "long"
      t.integer  "accuracy"
      t.float    "min_lat"
      t.float    "max_lat"
      t.float    "min_long"
      t.float    "max_long"
      t.string   "account_id"
      t.string   "posting_state"
      t.integer  "flagged_status"
      t.string   "origin_ip_address"
      t.string   "transit_ip_address"
    end

    add_index "postings", ["category"], name: "index_postings_on_category", using: :btree
    add_index "postings", ["category_group"], name: "index_postings_on_category_group", using: :btree
    add_index "postings", ["city"], name: "index_postings_on_city", using: :btree
    add_index "postings", ["country"], name: "index_postings_on_country", using: :btree
    add_index "postings", ["county"], name: "index_postings_on_county", using: :btree
    add_index "postings", ["external_id", "source"], name: "index_postings_on_external_id_and_source", using: :btree
    add_index "postings", ["id", "source", "category", "city"], name: "index_postings_on_id_and_source_and_category_and_city", using: :btree
    add_index "postings", ["id", "source", "category"], name: "index_postings_on_id_and_source_and_category", using: :btree
    add_index "postings", ["id", "source"], name: "index_postings_on_id_and_source", using: :btree
    add_index "postings", ["id"], name: "index_postings_on_id", using: :btree
    add_index "postings", ["locality"], name: "index_postings_on_locality", using: :btree
    add_index "postings", ["metro"], name: "index_postings_on_metro", using: :btree
    add_index "postings", ["region"], name: "index_postings_on_region", using: :btree
    add_index "postings", ["source"], name: "index_postings_on_source", using: :btree
    add_index "postings", ["state"], name: "index_postings_on_state", using: :btree
    add_index "postings", ["status"], name: "index_postings_on_status", using: :btree
    add_index "postings", ["timestamp"], name: "index_postings_on_timestamp", using: :btree
    add_index "postings", ["zipcode"], name: "index_postings_on_zipcode", using: :btree

    create_table "postings0" do |t|
      t.string   "source"
      t.string   "category"
      t.string   "external_id"
      t.string   "external_url",       limit: 512
      t.string   "heading"
      t.text     "body"
      t.text     "html",               limit: 16777215
      t.integer  "expires"
      t.string   "language"
      t.float    "price"
      t.string   "currency"
      t.text     "images"
      t.text     "annotations"
      t.string   "status"
      t.boolean  "flagged"
      t.boolean  "deleted",                                                     default: false
      t.boolean  "immortal",                                                    default: false
      t.integer  "timestamp"
      t.datetime "created_at",                                                                  null: false
      t.datetime "updated_at"
      t.string   "category_group"
      t.string   "country",            limit: 12
      t.string   "state",              limit: 12
      t.string   "metro",              limit: 12
      t.string   "region",             limit: 12
      t.string   "county",             limit: 12
      t.string   "city",               limit: 12
      t.string   "locality",           limit: 12
      t.string   "zipcode",            limit: 12
      t.decimal  "lat",                                 precision: 9, scale: 6
      t.decimal  "long",                                precision: 9, scale: 6
      t.integer  "accuracy"
      t.float    "min_lat"
      t.float    "max_lat"
      t.float    "min_long"
      t.float    "max_long"
      t.string   "account_id"
      t.string   "posting_state"
      t.integer  "flagged_status",                                              default: 0
      t.string   "origin_ip_address"
      t.string   "transit_ip_address"
      t.integer  "geolocation_status", limit: 1,                                default: 0
      t.string   "formatted_address"
    end

    add_index "postings0", ["category"], name: "index_postings0_on_category", using: :btree
    add_index "postings0", ["category_group"], name: "index_postings0_on_category_group", using: :btree
    add_index "postings0", ["city"], name: "index_postings0_on_city", using: :btree
    add_index "postings0", ["country"], name: "index_postings0_on_country", using: :btree
    add_index "postings0", ["county"], name: "index_postings0_on_county", using: :btree
    add_index "postings0", ["created_at"], name: "index_postings0_on_created_at", using: :btree
    add_index "postings0", ["deleted"], name: "index_postings0_on_deleted", using: :btree
    add_index "postings0", ["external_id", "source"], name: "index_postings0_on_external_id_and_source", using: :btree
    add_index "postings0", ["geolocation_status"], name: "index_postings0_on_geolocation_status", using: :btree
    add_index "postings0", ["locality"], name: "index_postings0_on_locality", using: :btree
    add_index "postings0", ["metro"], name: "index_postings0_on_metro", using: :btree
    add_index "postings0", ["posting_state"], name: "index_postings0_on_posting_state", using: :btree
    add_index "postings0", ["region"], name: "index_postings0_on_region", using: :btree
    add_index "postings0", ["source", "category", "city"], name: "index_postings0_on_source_and_category_and_city", using: :btree
    add_index "postings0", ["source", "category", "country"], name: "index_postings0_on_source_and_category_and_country", using: :btree
    add_index "postings0", ["source", "category", "county"], name: "index_postings0_on_source_and_category_and_county", using: :btree
    add_index "postings0", ["source", "category", "locality"], name: "index_postings0_on_source_and_category_and_locality", using: :btree
    add_index "postings0", ["source", "category", "metro"], name: "index_postings0_on_source_and_category_and_metro", using: :btree
    add_index "postings0", ["source", "category", "region"], name: "index_postings0_on_source_and_category_and_region", using: :btree
    add_index "postings0", ["source", "category", "state"], name: "index_postings0_on_source_and_category_and_state", using: :btree
    add_index "postings0", ["source", "category", "zipcode"], name: "index_postings0_on_source_and_category_and_zipcode", using: :btree
    add_index "postings0", ["source", "category"], name: "index_postings0_on_source_and_category", using: :btree
    add_index "postings0", ["source", "category_group"], name: "index_postings0_on_source_and_category_group", using: :btree
    add_index "postings0", ["source", "created_at"], name: "index_postings0_on_source_and_created_at", using: :btree
    add_index "postings0", ["source", "geolocation_status", "created_at"], name: "index_postings_on_source_and_geolocation_status_and_created_at", using: :btree
    add_index "postings0", ["source"], name: "index_postings0_on_source", using: :btree
    add_index "postings0", ["state"], name: "index_postings0_on_state", using: :btree
    add_index "postings0", ["status"], name: "index_postings0_on_status", using: :btree
    add_index "postings0", ["timestamp"], name: "index_postings0_on_timestamp", using: :btree
    add_index "postings0", ["zipcode"], name: "index_postings0_on_zipcode", using: :btree

    create_table "postings_old" do |t|
      t.string   "source",         limit: 5
      t.string   "category",       limit: 4
      t.string   "external_id"
      t.string   "external_url",   limit: 512
      t.string   "heading"
      t.text     "body"
      t.text     "html"
      t.integer  "expires"
      t.string   "language"
      t.float    "price"
      t.string   "currency"
      t.text     "images"
      t.text     "annotations"
      t.string   "status",         limit: 10
      t.boolean  "flagged"
      t.boolean  "deleted"
      t.boolean  "immortal"
      t.integer  "timestamp"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "category_group", limit: 4
      t.string   "country",        limit: 12
      t.string   "state",          limit: 12
      t.string   "metro",          limit: 12
      t.string   "region",         limit: 12
      t.string   "county",         limit: 12
      t.string   "city",           limit: 12
      t.string   "locality",       limit: 12
      t.string   "zipcode",        limit: 12
      t.float    "lat"
      t.float    "long"
      t.integer  "accuracy"
      t.float    "min_lat"
      t.float    "max_lat"
      t.float    "min_long"
      t.float    "max_long"
      t.string   "account_id"
      t.string   "posting_state"
    end

    add_index "postings_old", ["category"], name: "index_postings_old_on_category", using: :btree
    add_index "postings_old", ["category_group"], name: "index_postings_old_on_category_group", using: :btree
    add_index "postings_old", ["city"], name: "index_postings_old_on_city", using: :btree
    add_index "postings_old", ["country"], name: "index_postings_old_on_country", using: :btree
    add_index "postings_old", ["county"], name: "index_postings_old_on_county", using: :btree
    add_index "postings_old", ["external_id", "source"], name: "index_postings_old_on_external_id_and_source", using: :btree
    add_index "postings_old", ["id"], name: "index_postings_old_on_id", using: :btree
    add_index "postings_old", ["locality"], name: "index_postings_old_on_locality", using: :btree
    add_index "postings_old", ["metro"], name: "index_postings_old_on_metro", using: :btree
    add_index "postings_old", ["region"], name: "index_postings_old_on_region", using: :btree
    add_index "postings_old", ["source"], name: "index_postings_old_on_source", using: :btree
    add_index "postings_old", ["state"], name: "index_postings_old_on_state", using: :btree
    add_index "postings_old", ["status"], name: "index_postings_old_on_status", using: :btree
    add_index "postings_old", ["zipcode"], name: "index_postings_old_on_zipcode", using: :btree

    create_table "raw_postings" do |t|
      t.integer  "posting_id"
      t.text     "text",               limit: 2147483647
      t.string   "source",             limit: 5
      t.string   "category",           limit: 4
      t.text     "location",           limit: 255
      t.string   "external_id"
      t.string   "external_url",       limit: 512
      t.string   "heading"
      t.text     "body",               limit: 2147483647
      t.text     "html",               limit: 2147483647
      t.integer  "expires"
      t.string   "language"
      t.float    "price"
      t.string   "currency"
      t.text     "images"
      t.text     "annotations"
      t.string   "status",             limit: 10
      t.boolean  "flagged"
      t.boolean  "deleted"
      t.boolean  "immortal"
      t.integer  "timestamp"
      t.string   "category_group",     limit: 4
      t.string   "country",            limit: 120
      t.string   "state",              limit: 120
      t.string   "metro",              limit: 120
      t.string   "region",             limit: 120
      t.string   "county",             limit: 120
      t.string   "city",               limit: 120
      t.string   "locality",           limit: 120
      t.string   "zipcode",            limit: 12
      t.decimal  "lat",                                   precision: 9, scale: 6
      t.decimal  "long",                                  precision: 9, scale: 6
      t.integer  "accuracy"
      t.float    "min_lat"
      t.float    "max_lat"
      t.float    "min_long"
      t.float    "max_long"
      t.string   "account_id"
      t.string   "posting_state"
      t.integer  "flagged_status"
      t.string   "origin_ip_address"
      t.string   "transit_ip_address"
      t.integer  "geolocation_status", limit: 1,                                  default: 0
      t.string   "formatted_address"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "rejected",                                                      default: true
      t.string   "auth_token"
      t.integer  "validation_module"
      t.text     "error_messages"
      t.text     "warning_messages"
    end

    add_index "raw_postings", ["posting_id"], name: "index_raw_postings_on_posting_id", using: :btree

    create_table "recent_anchors" do |t|
      t.integer "anchor"
      t.boolean "anchor_freeze", default: false
    end

    create_table "requests_to_geocodes" do |t|
      t.integer  "timestamp_begin"
      t.integer  "count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "response_counts" do |t|
      t.string   "request_ip"
      t.integer  "count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "statistics" do |t|
      t.text     "data"
      t.datetime "timestamp"
      t.string   "type"
    end

    create_table "system_data" do |t|
      t.string   "name"
      t.text     "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "system_events" do |t|
      t.string   "event"
      t.text     "description", limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "system_states" do |t|
      t.integer  "geo_runners"
      t.integer  "mysql_processes"
      t.integer  "unicorn_workers"
      t.integer  "anchor_runners"
      t.integer  "bkpge_runners"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "active_unicorn_workers"
      t.integer  "unicorn_queue"
      t.integer  "three_scale_runners"
    end

    create_table "taps_exceptions" do |t|
      t.string   "number"
      t.text     "message"
      t.boolean  "notify"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "details"
      t.string   "module_name"
    end

    create_table "three_scale_stats" do |t|
      t.string   "auth_token"
      t.string   "metric"
      t.integer  "number"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "timestamps", primary_key: "timestamp" do |t|
    end

    add_index "timestamps", ["timestamp"], name: "index_timestamps_on_timestamp", using: :btree

    create_table "zipcodes" do |t|
      t.string "zipcode"
      t.string "lat"
      t.string "long"
    end

    add_index "zipcodes", ["zipcode"], name: "index_zipcodes_on_zipcode", using: :btree

    execute "INSERT INTO current_volume (volume) VALUES (0);"
    execute "INSERT INTO first_volume (volume) VALUES (0);"
    execute "INSERT INTO last_volume (volume) VALUES (0);"
  end
end
