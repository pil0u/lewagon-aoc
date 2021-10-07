# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_07_153221) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batches", force: :cascade do |t|
    t.integer "number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_cities_on_name", unique: true
  end

  create_table "scores", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "day", limit: 2
    t.integer "challenge", limit: 2
    t.bigint "completion_unix_time"
    t.integer "score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_scores_on_user_id"
  end

  create_table "states", force: :cascade do |t|
    t.datetime "last_api_check_start"
    t.datetime "last_api_check_end"
    t.integer "slots_room_1"
    t.integer "slots_room_2"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.string "username"
    t.integer "aoc_id"
    t.bigint "batch_id"
    t.bigint "city_id"
    t.index ["aoc_id"], name: "index_users_on_aoc_id"
    t.index ["batch_id"], name: "index_users_on_batch_id"
    t.index ["city_id"], name: "index_users_on_city_id"
  end

  add_foreign_key "scores", "users"
  add_foreign_key "users", "batches"
  add_foreign_key "users", "cities"
end
