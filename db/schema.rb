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

ActiveRecord::Schema[7.0].define(version: 2022_08_16_211501) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "number"
    t.datetime "updated_at", null: false
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.datetime "created_at"
    t.string "data_source"
    t.bigint "query_id"
    t.text "statement"
    t.bigint "user_id"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.string "check_type"
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.text "emails"
    t.datetime "last_run_at"
    t.text "message"
    t.bigint "query_id"
    t.string "schedule"
    t.text "slack_channels"
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dashboard_id"
    t.integer "position"
    t.bigint "query_id"
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.string "data_source"
    t.text "description"
    t.string "name"
    t.text "statement"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "cities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "size"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cities_on_name", unique: true
  end

  create_table "completions", force: :cascade do |t|
    t.integer "challenge", limit: 2
    t.bigint "completion_unix_time"
    t.integer "day", limit: 2
    t.integer "rank_in_batch"
    t.integer "rank_in_city"
    t.integer "rank_solo"
    t.integer "score_in_batch"
    t.integer "score_in_city"
    t.integer "score_solo"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "day", "challenge"], name: "index_completions_on_user_id_and_day_and_challenge", unique: true
    t.index ["user_id"], name: "index_completions_on_user_id"
  end

  create_table "states", force: :cascade do |t|
    t.datetime "last_api_fetch_end", precision: nil
    t.datetime "last_api_fetch_start", precision: nil
  end

  create_table "users", force: :cascade do |t|
    t.boolean "accepted_terms", default: false
    t.integer "aoc_id"
    t.bigint "batch_id"
    t.bigint "city_id"
    t.datetime "created_at", null: false
    t.boolean "entered_hardcore", default: false
    t.string "github_username"
    t.string "provider"
    t.boolean "synced", default: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["aoc_id"], name: "index_users_on_aoc_id"
    t.index ["batch_id"], name: "index_users_on_batch_id"
    t.index ["city_id"], name: "index_users_on_city_id"
  end

  add_foreign_key "completions", "users"
  add_foreign_key "users", "batches"
  add_foreign_key "users", "cities"

  create_view "completion_ranks", materialized: true, sql_definition: <<-SQL
      SELECT co.id AS completion_id,
      rank() OVER (PARTITION BY co.day, co.challenge ORDER BY co.completion_unix_time) AS in_contest,
      rank() OVER (PARTITION BY u.batch_id, co.day, co.challenge ORDER BY co.completion_unix_time) AS in_batch,
      rank() OVER (PARTITION BY u.city_id, co.day, co.challenge ORDER BY co.completion_unix_time) AS in_city
     FROM (completions co
       LEFT JOIN users u ON ((co.user_id = u.id)))
    WHERE (co.completion_unix_time IS NOT NULL);
  SQL
  add_index "completion_ranks", ["completion_id"], name: "index_completion_ranks_on_completion_id", unique: true
  add_index "completion_ranks", ["in_batch"], name: "index_completion_ranks_on_in_batch"
  add_index "completion_ranks", ["in_city"], name: "index_completion_ranks_on_in_city"
  add_index "completion_ranks", ["in_contest"], name: "index_completion_ranks_on_in_contest"

  create_view "point_values", materialized: true, sql_definition: <<-SQL
      SELECT co.id AS completion_id,
      ((( SELECT count(*) AS count
             FROM users
            WHERE users.synced) - cr.in_contest) + 1) AS in_contest,
      ((( SELECT count(*) AS count
             FROM users
            WHERE (users.synced AND (users.batch_id = u.batch_id))) - cr.in_batch) + 1) AS in_batch,
      ((( SELECT count(*) AS count
             FROM users
            WHERE (users.synced AND (users.city_id = u.city_id))) - cr.in_city) + 1) AS in_city
     FROM ((completions co
       LEFT JOIN users u ON ((co.user_id = u.id)))
       LEFT JOIN completion_ranks cr ON ((cr.completion_id = co.id)))
    WHERE (co.completion_unix_time IS NOT NULL);
  SQL
  add_index "point_values", ["completion_id"], name: "index_point_values_on_completion_id", unique: true

  create_view "scores", materialized: true, sql_definition: <<-SQL
      SELECT u.id AS user_id,
      COALESCE(sum(pv.in_contest), (0)::numeric) AS in_contest,
      COALESCE(sum(pv.in_batch), (0)::numeric) AS in_batch,
      COALESCE(sum(pv.in_city), (0)::numeric) AS in_city
     FROM ((users u
       LEFT JOIN completions co ON ((co.user_id = u.id)))
       LEFT JOIN point_values pv ON ((pv.completion_id = co.id)))
    GROUP BY u.id;
  SQL
  add_index "scores", ["user_id"], name: "index_scores_on_user_id", unique: true

  create_view "ranks", materialized: true, sql_definition: <<-SQL
      SELECT u.id AS user_id,
      rank() OVER (ORDER BY s.in_contest DESC) AS in_contest,
      rank() OVER (PARTITION BY b.id ORDER BY s.in_batch DESC) AS in_batch,
      rank() OVER (PARTITION BY ci.id ORDER BY s.in_city DESC) AS in_city
     FROM (((users u
       LEFT JOIN scores s ON ((s.user_id = u.id)))
       LEFT JOIN batches b ON ((u.batch_id = b.id)))
       LEFT JOIN cities ci ON ((u.city_id = ci.id)))
    ORDER BY s.in_contest DESC;
  SQL
  add_index "ranks", ["user_id"], name: "index_ranks_on_user_id", unique: true

  create_view "batch_contributions", materialized: true, sql_definition: <<-SQL
      WITH synced_user_numbers AS (
           SELECT GREATEST(3, (ceil(percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((synced_user_counts.value)::double precision))))::integer) AS median
             FROM ( SELECT count(u.*) AS value
                     FROM (batches
                       LEFT JOIN users u ON ((u.batch_id = batches.id)))
                    WHERE u.synced
                    GROUP BY batches.id) synced_user_counts
          )
   SELECT co.id AS completion_id,
          CASE
              WHEN (cr.in_batch <= ( SELECT synced_user_numbers.median
                 FROM synced_user_numbers)) THEN pv.in_contest
              ELSE (0)::bigint
          END AS points
     FROM ((completions co
       LEFT JOIN point_values pv ON ((pv.completion_id = co.id)))
       LEFT JOIN completion_ranks cr ON ((cr.completion_id = co.id)));
  SQL
  add_index "batch_contributions", ["completion_id"], name: "index_batch_contributions_on_completion_id", unique: true

  create_view "city_contributions", materialized: true, sql_definition: <<-SQL
      WITH synced_user_numbers AS (
           SELECT GREATEST(3, (ceil(percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((synced_user_counts.value)::double precision))))::integer) AS median
             FROM ( SELECT count(u.*) AS value
                     FROM (cities
                       LEFT JOIN users u ON ((u.city_id = cities.id)))
                    WHERE u.synced
                    GROUP BY cities.id) synced_user_counts
          )
   SELECT co.id AS completion_id,
          CASE
              WHEN (cr.in_city <= ( SELECT synced_user_numbers.median
                 FROM synced_user_numbers)) THEN pv.in_contest
              ELSE (0)::bigint
          END AS points
     FROM ((completions co
       LEFT JOIN point_values pv ON ((pv.completion_id = co.id)))
       LEFT JOIN completion_ranks cr ON ((cr.completion_id = co.id)));
  SQL
  add_index "city_contributions", ["completion_id"], name: "index_city_contributions_on_completion_id", unique: true

  create_view "batch_points", materialized: true, sql_definition: <<-SQL
      WITH synced_user_numbers AS (
           SELECT GREATEST(3, (ceil(percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((synced_user_counts.value)::double precision))))::integer) AS median
             FROM ( SELECT count(u_1.*) AS value
                     FROM (batches
                       LEFT JOIN users u_1 ON ((u_1.batch_id = batches.id)))
                    WHERE u_1.synced
                    GROUP BY batches.id) synced_user_counts
          )
   SELECT b.id AS batch_id,
      co.day,
      co.challenge,
      COALESCE(sum(bc.points), (0)::numeric) AS points,
      rank() OVER (PARTITION BY co.day, co.challenge ORDER BY (sum(bc.points)) DESC) AS rank,
      count(*) FILTER (WHERE (co.id IS NOT NULL)) AS participating_users,
      (count(*) FILTER (WHERE (co.id IS NOT NULL)) >= ( SELECT synced_user_numbers.median
             FROM synced_user_numbers)) AS complete
     FROM (((batches b
       LEFT JOIN users u ON ((u.batch_id = b.id)))
       LEFT JOIN completions co ON ((co.user_id = u.id)))
       LEFT JOIN batch_contributions bc ON ((bc.completion_id = co.id)))
    GROUP BY b.id, co.day, co.challenge
    ORDER BY co.day, co.challenge, COALESCE(sum(bc.points), (0)::numeric) DESC;
  SQL
  add_index "batch_points", ["batch_id", "day", "challenge"], name: "index_batch_points_on_batch_id_and_day_and_challenge", unique: true

  create_view "batch_scores", materialized: true, sql_definition: <<-SQL
      SELECT scores.batch_id,
      scores.score AS in_contest,
      rank() OVER (ORDER BY scores.score DESC) AS rank
     FROM ( SELECT batch_points.batch_id,
              sum(batch_points.points) AS score
             FROM batch_points
            GROUP BY batch_points.batch_id) scores;
  SQL
  add_index "batch_scores", ["batch_id"], name: "index_batch_scores_on_batch_id", unique: true

  create_view "city_points", materialized: true, sql_definition: <<-SQL
      WITH synced_user_numbers AS (
           SELECT GREATEST(3, (ceil(percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((synced_user_counts.value)::double precision))))::integer) AS median
             FROM ( SELECT count(u_1.*) AS value
                     FROM (cities
                       LEFT JOIN users u_1 ON ((u_1.city_id = cities.id)))
                    WHERE u_1.synced
                    GROUP BY cities.id) synced_user_counts
          )
   SELECT c.id AS city_id,
      co.day,
      co.challenge,
      COALESCE(sum(cc.points), (0)::numeric) AS points,
      rank() OVER (PARTITION BY co.day, co.challenge ORDER BY (sum(cc.points)) DESC) AS rank,
      count(*) FILTER (WHERE (co.id IS NOT NULL)) AS participating_users,
      (count(*) FILTER (WHERE (co.id IS NOT NULL)) >= ( SELECT synced_user_numbers.median
             FROM synced_user_numbers)) AS complete
     FROM (((cities c
       LEFT JOIN users u ON ((u.city_id = c.id)))
       LEFT JOIN completions co ON ((co.user_id = u.id)))
       LEFT JOIN city_contributions cc ON ((cc.completion_id = co.id)))
    GROUP BY c.id, co.day, co.challenge
    ORDER BY co.day, co.challenge, COALESCE(sum(cc.points), (0)::numeric) DESC;
  SQL
  add_index "city_points", ["city_id", "day", "challenge"], name: "index_city_points_on_city_id_and_day_and_challenge", unique: true

  create_view "city_scores", materialized: true, sql_definition: <<-SQL
      SELECT scores.city_id,
      scores.score AS in_contest,
      rank() OVER (ORDER BY scores.score DESC) AS rank
     FROM ( SELECT city_points.city_id,
              sum(city_points.points) AS score
             FROM city_points
            GROUP BY city_points.city_id) scores;
  SQL
  add_index "city_scores", ["city_id"], name: "index_city_scores_on_city_id", unique: true

end
