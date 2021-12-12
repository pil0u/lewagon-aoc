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

ActiveRecord::Schema.define(version: 2021_12_21_072305) do

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

  create_view "exercises", materialized: true, sql_definition: <<-SQL
      SELECT days.day,
      challenges.challenge
     FROM (generate_series(1, 25) days(day)
       CROSS JOIN generate_series(1, 2) challenges(challenge))
    ORDER BY days.day, challenges.challenge;
  SQL
  create_view "completion_ranks", materialized: true, sql_definition: <<-SQL
      SELECT e.day,
      e.challenge,
      u.id AS user_id,
      co.id AS completion_id,
          CASE
              WHEN (co.completion_unix_time IS NULL) THEN NULL::bigint
              ELSE rank() OVER (PARTITION BY e.day, e.challenge ORDER BY co.completion_unix_time)
          END AS in_contest,
          CASE
              WHEN (co.completion_unix_time IS NULL) THEN NULL::bigint
              ELSE rank() OVER (PARTITION BY u.batch_id, e.day, e.challenge ORDER BY co.completion_unix_time)
          END AS in_batch,
          CASE
              WHEN (co.completion_unix_time IS NULL) THEN NULL::bigint
              ELSE rank() OVER (PARTITION BY u.city_id, e.day, e.challenge ORDER BY co.completion_unix_time)
          END AS in_city
     FROM ((exercises e
       CROSS JOIN users u)
       LEFT JOIN completions co ON (((co.day = e.day) AND (co.challenge = e.challenge) AND (co.user_id = u.id))));
  SQL
  add_index "completion_ranks", ["completion_id"], name: "index_completion_ranks_on_completion_id", unique: true
  add_index "completion_ranks", ["user_id", "day", "challenge"], name: "index_completion_ranks_on_user_id_and_day_and_challenge", unique: true

  create_view "point_values", materialized: true, sql_definition: <<-SQL
      SELECT cr.user_id,
      cr.day,
      cr.challenge,
      cr.completion_id,
          CASE
              WHEN (cr.in_contest IS NULL) THEN (0)::bigint
              ELSE ((( SELECT count(*) AS count
                 FROM users
                WHERE users.synced) - cr.in_contest) + 1)
          END AS in_contest,
      u.batch_id,
          CASE
              WHEN (cr.in_batch IS NULL) THEN (0)::bigint
              ELSE ((( SELECT count(*) AS count
                 FROM users
                WHERE (users.synced AND (users.batch_id = u.batch_id))) - cr.in_batch) + 1)
          END AS in_batch,
      u.city_id,
          CASE
              WHEN (cr.in_city IS NULL) THEN (0)::bigint
              ELSE ((( SELECT count(*) AS count
                 FROM users
                WHERE (users.synced AND (users.city_id = u.city_id))) - cr.in_city) + 1)
          END AS in_city
     FROM (users u
       LEFT JOIN completion_ranks cr ON ((cr.user_id = u.id)));
  SQL
  add_index "point_values", ["completion_id"], name: "index_point_values_on_completion_id", unique: true
  add_index "point_values", ["in_batch"], name: "index_point_values_on_in_batch"
  add_index "point_values", ["in_city"], name: "index_point_values_on_in_city"
  add_index "point_values", ["in_contest"], name: "index_point_values_on_in_contest"
  add_index "point_values", ["user_id", "day", "challenge"], name: "index_point_values_on_user_id_and_day_and_challenge", unique: true

  create_view "user_points", materialized: true, sql_definition: <<-SQL
      SELECT point_values.day,
      point_values.challenge,
      point_values.completion_id,
      point_values.user_id,
      point_values.in_contest,
      dense_rank() OVER (ORDER BY point_values.in_contest DESC NULLS LAST) AS rank_in_contest,
      point_values.batch_id,
      point_values.in_batch,
      dense_rank() OVER (PARTITION BY point_values.batch_id ORDER BY point_values.in_batch DESC NULLS LAST) AS rank_in_batch,
      point_values.city_id,
      point_values.in_city,
      dense_rank() OVER (PARTITION BY point_values.city_id ORDER BY point_values.in_city DESC NULLS LAST) AS rank_in_city
     FROM point_values;
  SQL
  add_index "user_points", ["batch_id"], name: "index_user_points_on_batch_id"
  add_index "user_points", ["city_id"], name: "index_user_points_on_city_id"
  add_index "user_points", ["rank_in_batch"], name: "index_user_points_on_rank_in_batch"
  add_index "user_points", ["rank_in_city"], name: "index_user_points_on_rank_in_city"
  add_index "user_points", ["rank_in_contest"], name: "index_user_points_on_rank_in_contest"
  add_index "user_points", ["user_id", "day", "challenge"], name: "index_user_points_on_user_id_and_day_and_challenge", unique: true

  create_view "scores", materialized: true, sql_definition: <<-SQL
      SELECT scores.user_id,
      scores.score AS in_contest,
      dense_rank() OVER (ORDER BY scores.score DESC) AS rank_in_contest,
      scores.batch_id,
      scores.batch_score AS in_batch,
      dense_rank() OVER (PARTITION BY scores.batch_id ORDER BY scores.batch_score DESC) AS rank_in_batch,
      scores.city_id,
      scores.city_score AS in_city,
      dense_rank() OVER (PARTITION BY scores.city_id ORDER BY scores.city_score DESC) AS rank_in_city
     FROM ( SELECT user_points.user_id,
              (sum(user_points.in_contest))::integer AS score,
              user_points.batch_id,
              (sum(user_points.in_batch))::integer AS batch_score,
              user_points.city_id,
              (sum(user_points.in_city))::integer AS city_score
             FROM user_points
            GROUP BY user_points.user_id, user_points.batch_id, user_points.city_id) scores;
  SQL
  add_index "scores", ["rank_in_batch"], name: "index_scores_on_rank_in_batch"
  add_index "scores", ["rank_in_city"], name: "index_scores_on_rank_in_city"
  add_index "scores", ["rank_in_contest"], name: "index_scores_on_rank_in_contest"
  add_index "scores", ["user_id"], name: "index_scores_on_user_id", unique: true

  create_view "batch_contributions", materialized: true, sql_definition: <<-SQL
      SELECT up.batch_id,
      up.day,
      up.challenge,
      up.completion_id,
      (up.completion_id IS NOT NULL) AS participated,
      up.user_id,
          CASE
              WHEN (up.rank_in_batch <= ( VALUES (max_allowed_contributors_in_batch()))) THEN up.in_contest
              ELSE (0)::bigint
          END AS in_contest,
      up.city_id,
          CASE
              WHEN (up.rank_in_batch <= ( VALUES (max_allowed_contributors_in_batch()))) THEN up.in_city
              ELSE (0)::bigint
          END AS in_city
     FROM user_points up;
  SQL
  add_index "batch_contributions", ["completion_id"], name: "index_batch_contributions_on_completion_id", unique: true
  add_index "batch_contributions", ["participated"], name: "index_batch_contributions_on_participated"
  add_index "batch_contributions", ["user_id", "day", "challenge"], name: "index_batch_contributions_on_user_id_and_day_and_challenge", unique: true

  create_view "city_contributions", materialized: true, sql_definition: <<-SQL
      SELECT up.city_id,
      up.day,
      up.challenge,
      up.completion_id,
      (up.completion_id IS NOT NULL) AS participated,
      up.user_id,
          CASE
              WHEN (up.rank_in_batch <= ( VALUES (max_allowed_contributors_in_city()))) THEN up.in_contest
              ELSE (0)::bigint
          END AS in_contest,
      up.batch_id,
          CASE
              WHEN (up.rank_in_batch <= ( VALUES (max_allowed_contributors_in_city()))) THEN up.in_batch
              ELSE (0)::bigint
          END AS in_batch
     FROM user_points up;
  SQL
  add_index "city_contributions", ["completion_id"], name: "index_city_contributions_on_completion_id", unique: true
  add_index "city_contributions", ["participated"], name: "index_city_contributions_on_participated"
  add_index "city_contributions", ["user_id", "day", "challenge"], name: "index_city_contributions_on_user_id_and_day_and_challenge", unique: true

  create_view "batch_points", materialized: true, sql_definition: <<-SQL
      SELECT bc.batch_id,
      bc.day,
      bc.challenge,
      (sum(bc.in_contest))::integer AS in_contest,
      dense_rank() OVER (PARTITION BY bc.day, bc.challenge ORDER BY (sum(bc.in_contest)) DESC) AS rank_in_contest,
      count(*) FILTER (WHERE bc.participated) AS participating_users,
      (count(*) FILTER (WHERE bc.participated) >= ( VALUES (max_allowed_contributors_in_batch()))) AS complete
     FROM batch_contributions bc
    GROUP BY bc.batch_id, bc.day, bc.challenge;
  SQL
  add_index "batch_points", ["batch_id", "day", "challenge"], name: "index_batch_points_on_batch_id_and_day_and_challenge", unique: true

  create_view "batch_scores", materialized: true, sql_definition: <<-SQL
      SELECT batches.id AS batch_id,
      COALESCE(scores.in_contest, (0)::bigint) AS in_contest,
      dense_rank() OVER (ORDER BY scores.in_contest DESC NULLS LAST) AS rank_in_contest
     FROM (batches
       LEFT JOIN ( SELECT batch_points.batch_id,
              sum(batch_points.in_contest) AS in_contest
             FROM batch_points
            GROUP BY batch_points.batch_id) scores ON ((batches.id = scores.batch_id)));
  SQL
  add_index "batch_scores", ["batch_id"], name: "index_batch_scores_on_batch_id", unique: true

  create_view "city_points", materialized: true, sql_definition: <<-SQL
      SELECT cc.city_id,
      cc.day,
      cc.challenge,
      (sum(cc.in_contest))::integer AS in_contest,
      dense_rank() OVER (PARTITION BY cc.day, cc.challenge ORDER BY (sum(cc.in_contest)) DESC) AS rank_in_contest,
      count(*) FILTER (WHERE cc.participated) AS participating_users,
      (count(*) FILTER (WHERE cc.participated) >= ( VALUES (max_allowed_contributors_in_batch()))) AS complete
     FROM city_contributions cc
    GROUP BY cc.city_id, cc.day, cc.challenge;
  SQL
  add_index "city_points", ["city_id", "day", "challenge"], name: "index_city_points_on_city_id_and_day_and_challenge", unique: true

  create_view "city_scores", materialized: true, sql_definition: <<-SQL
      SELECT cities.id AS city_id,
      COALESCE(scores.in_contest, (0)::bigint) AS in_contest,
      dense_rank() OVER (ORDER BY scores.in_contest DESC NULLS LAST) AS rank_in_contest
     FROM (cities
       LEFT JOIN ( SELECT city_points.city_id,
              sum(city_points.in_contest) AS in_contest
             FROM city_points
            GROUP BY city_points.city_id) scores ON ((cities.id = scores.city_id)));
  SQL
  add_index "city_scores", ["city_id"], name: "index_city_scores_on_city_id", unique: true

  create_function :max_allowed_contributors_in_batch, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.max_allowed_contributors_in_batch()
       RETURNS integer
       LANGUAGE sql
       STABLE
      AS $function$
      SELECT GREATEST(3, CEIL(percentile_cont(0.5) WITHIN GROUP (ORDER BY value))::int) AS median
      FROM (
        SELECT COUNT(u.*) AS value
        FROM batches
        LEFT JOIN users AS u
        ON u.batch_id = batches.id
        WHERE u.synced
        GROUP BY batches.id
      ) AS synced_user_counts

      $function$
  SQL
  create_function :max_allowed_contributors_in_city, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.max_allowed_contributors_in_city()
       RETURNS integer
       LANGUAGE sql
       STABLE
      AS $function$
      SELECT GREATEST(3, CEIL(percentile_cont(0.5) WITHIN GROUP (ORDER BY value))::int) AS median
      FROM (
        SELECT COUNT(u.*) AS value
        FROM cities
        LEFT JOIN users AS u
        ON u.city_id = cities.id
        WHERE u.synced
        GROUP BY cities.id
      ) AS synced_user_counts

      $function$
  SQL

end
