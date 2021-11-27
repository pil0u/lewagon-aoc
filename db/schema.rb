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

ActiveRecord::Schema.define(version: 2021_11_27_031000) do

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

  create_table "completions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "day", limit: 2
    t.integer "challenge", limit: 2
    t.bigint "completion_unix_time"
    t.datetime "updated_at", precision: 6, null: false
    t.integer "rank_solo"
    t.integer "rank_in_batch"
    t.integer "rank_in_city"
    t.integer "score_solo"
    t.integer "score_in_batch"
    t.integer "score_in_city"
    t.index ["user_id", "day", "challenge"], name: "index_completions_on_user_id_and_day_and_challenge", unique: true
    t.index ["user_id"], name: "index_completions_on_user_id"
  end

  create_table "states", force: :cascade do |t|
    t.datetime "last_api_fetch_start"
    t.datetime "last_api_fetch_end"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.string "username"
    t.integer "aoc_id"
    t.boolean "synced", default: false
    t.bigint "batch_id"
    t.bigint "city_id"
    t.index ["aoc_id"], name: "index_users_on_aoc_id"
    t.index ["batch_id"], name: "index_users_on_batch_id"
    t.index ["city_id"], name: "index_users_on_city_id"
  end

  add_foreign_key "completions", "users"
  add_foreign_key "users", "batches"
  add_foreign_key "users", "cities"

  create_view "point_values", materialized: true, sql_definition: <<-SQL
      SELECT co.id AS completion_id,
      dense_rank() OVER (PARTITION BY co.day, co.challenge ORDER BY co.completion_unix_time) AS in_contest,
      dense_rank() OVER (PARTITION BY b.id, co.day, co.challenge ORDER BY co.completion_unix_time) AS in_batch,
      dense_rank() OVER (PARTITION BY ci.id, co.day, co.challenge ORDER BY co.completion_unix_time) AS in_city
     FROM (((completions co
       LEFT JOIN users u ON ((co.user_id = u.id)))
       LEFT JOIN batches b ON ((u.batch_id = b.id)))
       LEFT JOIN cities ci ON ((u.city_id = ci.id)));
  SQL
  add_index "point_values", ["completion_id"], name: "index_point_values_on_completion_id", unique: true

  create_view "scores", materialized: true, sql_definition: <<-SQL
      SELECT u.id AS user_id,
      sum(pv.in_contest) AS in_contest,
      sum(pv.in_batch) AS in_batch,
      sum(pv.in_city) AS in_city
     FROM ((users u
       LEFT JOIN completions co ON ((co.user_id = u.id)))
       LEFT JOIN point_values pv ON ((pv.completion_id = co.id)))
    GROUP BY u.id;
  SQL
  add_index "scores", ["user_id"], name: "index_scores_on_user_id", unique: true

  create_view "ranks", materialized: true, sql_definition: <<-SQL
      SELECT u.id AS user_id,
      dense_rank() OVER (ORDER BY s.in_contest) AS in_contest,
      dense_rank() OVER (PARTITION BY b.id ORDER BY s.in_batch) AS in_batch,
      dense_rank() OVER (PARTITION BY ci.id ORDER BY s.in_city) AS in_city
     FROM (((users u
       LEFT JOIN scores s ON ((s.user_id = u.id)))
       LEFT JOIN batches b ON ((u.batch_id = b.id)))
       LEFT JOIN cities ci ON ((u.city_id = ci.id)));
  SQL
  add_index "ranks", ["user_id"], name: "index_ranks_on_user_id", unique: true

end
