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

ActiveRecord::Schema[7.2].define(version: 2024_11_16_190301) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "nature"
    t.datetime "unlocked_at", precision: nil
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["nature"], name: "index_achievements_on_nature"
    t.index ["unlocked_at"], name: "index_achievements_on_unlocked_at"
    t.index ["user_id"], name: "index_achievements_on_user_id"
  end

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

  create_table "buddies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day"
    t.integer "id_1"
    t.integer "id_2"
    t.datetime "updated_at", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "size"
    t.integer "top_contributors"
    t.datetime "updated_at", null: false
    t.string "vanity_name"
    t.index ["name"], name: "index_cities_on_name", unique: true
  end

  create_table "city_points", force: :cascade do |t|
    t.string "cache_fingerprint"
    t.integer "challenge"
    t.bigint "city_id", null: false
    t.integer "contributor_count"
    t.datetime "created_at", null: false
    t.integer "day"
    t.decimal "score"
    t.integer "total_score"
    t.datetime "updated_at", null: false
    t.index ["cache_fingerprint"], name: "index_city_points_on_cache_fingerprint"
    t.index ["city_id"], name: "index_city_points_on_city_id"
    t.index ["day", "challenge", "city_id", "cache_fingerprint"], name: "unique_daychallcityfing_on_city_points", unique: true
  end

  create_table "city_scores", force: :cascade do |t|
    t.string "cache_fingerprint"
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.integer "current_day_part_1_contributors"
    t.integer "current_day_part_2_contributors"
    t.integer "order"
    t.integer "rank"
    t.integer "score"
    t.datetime "updated_at", null: false
    t.index ["cache_fingerprint"], name: "index_city_scores_on_cache_fingerprint"
    t.index ["city_id", "cache_fingerprint"], name: "index_city_scores_on_city_id_and_cache_fingerprint", unique: true
    t.index ["city_id"], name: "index_city_scores_on_city_id"
    t.index ["order"], name: "index_city_scores_on_order"
    t.index ["rank"], name: "index_city_scores_on_rank"
  end

  create_table "completions", force: :cascade do |t|
    t.integer "challenge", limit: 2
    t.bigint "completion_unix_time"
    t.datetime "created_at", null: false
    t.integer "day", limit: 2
    t.virtual "duration", type: :interval, as: "\nCASE\n    WHEN (completion_unix_time IS NOT NULL) THEN (to_timestamp((completion_unix_time)::double precision) - to_timestamp(((1733029200)::double precision + (((day - 1) * 86400))::double precision)))\n    ELSE NULL::interval\nEND", stored: true
    t.virtual "release_date", type: :datetime, precision: nil, as: "to_timestamp(((1733029200)::double precision + (((day - 1) * 86400))::double precision))", stored: true
    t.bigint "user_id", null: false
    t.index ["user_id", "day", "challenge"], name: "index_completions_on_user_id_and_day_and_challenge", unique: true
    t.index ["user_id"], name: "index_completions_on_user_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "insanity_points", force: :cascade do |t|
    t.string "cache_fingerprint", null: false
    t.integer "challenge"
    t.bigint "completion_id"
    t.datetime "created_at", null: false
    t.integer "day"
    t.interval "duration"
    t.integer "score"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cache_fingerprint"], name: "index_insanity_points_on_cache_fingerprint"
    t.index ["completion_id"], name: "index_insanity_points_on_completion_id"
    t.index ["day", "challenge", "user_id", "cache_fingerprint"], name: "unique_daychalluserfetch_on_insanity_points", unique: true
    t.index ["user_id"], name: "index_insanity_points_on_user_id"
  end

  create_table "insanity_scores", force: :cascade do |t|
    t.string "cache_fingerprint", null: false
    t.datetime "created_at", null: false
    t.integer "current_day_score"
    t.integer "order"
    t.integer "rank"
    t.integer "score"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cache_fingerprint"], name: "index_insanity_scores_on_cache_fingerprint"
    t.index ["order"], name: "index_insanity_scores_on_order"
    t.index ["rank"], name: "index_insanity_scores_on_rank"
    t.index ["user_id", "cache_fingerprint"], name: "index_insanity_scores_on_user_id_and_cache_fingerprint", unique: true
    t.index ["user_id"], name: "index_insanity_scores_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "puzzles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "slack_url"
    t.string "thread_ts"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_puzzles_on_date", unique: true
  end

  create_table "reactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "reaction_type", null: false
    t.bigint "snippet_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["snippet_id"], name: "index_reactions_on_snippet_id"
    t.index ["user_id", "snippet_id"], name: "index_reactions_on_user_id_and_snippet_id", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "snippets", force: :cascade do |t|
    t.integer "challenge"
    t.text "code"
    t.datetime "created_at", null: false
    t.integer "day"
    t.text "language"
    t.string "slack_url"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "day", "challenge", "language"], name: "index_snippets_on_user_id_and_day_and_challenge_and_language", unique: true
    t.index ["user_id"], name: "index_snippets_on_user_id"
  end

  create_table "solo_points", force: :cascade do |t|
    t.string "cache_fingerprint", null: false
    t.integer "challenge"
    t.bigint "completion_id"
    t.datetime "created_at", null: false
    t.integer "day"
    t.integer "score"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cache_fingerprint"], name: "index_solo_points_on_cache_fingerprint"
    t.index ["completion_id"], name: "index_solo_points_on_completion_id"
    t.index ["day", "challenge", "user_id", "cache_fingerprint"], name: "unique_daychalluserfetch_on_solo_points", unique: true
    t.index ["user_id"], name: "index_solo_points_on_user_id"
  end

  create_table "solo_scores", force: :cascade do |t|
    t.string "cache_fingerprint"
    t.datetime "created_at", null: false
    t.integer "current_day_score"
    t.integer "order"
    t.integer "rank"
    t.integer "score"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cache_fingerprint"], name: "index_solo_scores_on_cache_fingerprint"
    t.index ["order"], name: "index_solo_scores_on_order"
    t.index ["rank"], name: "index_solo_scores_on_rank"
    t.index ["user_id", "cache_fingerprint"], name: "index_solo_scores_on_user_id_and_cache_fingerprint", unique: true
    t.index ["user_id"], name: "index_solo_scores_on_user_id"
  end

  create_table "squad_points", force: :cascade do |t|
    t.string "cache_fingerprint"
    t.integer "challenge"
    t.datetime "created_at", null: false
    t.integer "day"
    t.integer "score"
    t.bigint "squad_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cache_fingerprint"], name: "index_squad_points_on_cache_fingerprint"
    t.index ["day", "challenge", "squad_id", "cache_fingerprint"], name: "unique_daychallsquadcache_on_solo_points", unique: true
    t.index ["squad_id"], name: "index_squad_points_on_squad_id"
  end

  create_table "squad_scores", force: :cascade do |t|
    t.string "cache_fingerprint"
    t.datetime "created_at", null: false
    t.integer "current_day_score"
    t.integer "order"
    t.integer "rank"
    t.integer "score"
    t.bigint "squad_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cache_fingerprint"], name: "index_squad_scores_on_cache_fingerprint"
    t.index ["order"], name: "index_squad_scores_on_order"
    t.index ["rank"], name: "index_squad_scores_on_rank"
    t.index ["squad_id", "cache_fingerprint"], name: "index_squad_scores_on_squad_id_and_cache_fingerprint", unique: true
    t.index ["squad_id"], name: "index_squad_scores_on_squad_id"
  end

  create_table "squads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "name"
    t.integer "pin"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_squads_on_name", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.integer "completions_fetched"
    t.datetime "fetch_api_begin", precision: nil
    t.datetime "fetch_api_end", precision: nil
    t.index ["completions_fetched"], name: "index_states_on_completions_fetched"
    t.index ["fetch_api_begin"], name: "index_states_on_fetch_api_begin"
    t.index ["fetch_api_end"], name: "index_states_on_fetch_api_end"
  end

  create_table "user_day_scores", force: :cascade do |t|
    t.string "cache_fingerprint"
    t.datetime "created_at", null: false
    t.integer "day"
    t.integer "order"
    t.bigint "part_1_completion_id"
    t.bigint "part_2_completion_id"
    t.integer "rank"
    t.integer "score"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cache_fingerprint"], name: "index_user_day_scores_on_cache_fingerprint"
    t.index ["day", "user_id", "cache_fingerprint"], name: "unique_dayusercache_on_user_day_scores", unique: true
    t.index ["order"], name: "index_user_day_scores_on_order"
    t.index ["part_1_completion_id"], name: "index_user_day_scores_on_part_1_completion_id"
    t.index ["part_2_completion_id"], name: "index_user_day_scores_on_part_2_completion_id"
    t.index ["rank"], name: "index_user_day_scores_on_rank"
    t.index ["user_id"], name: "index_user_day_scores_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "accepted_coc", default: false, null: false
    t.integer "aoc_id"
    t.bigint "batch_id"
    t.bigint "city_id"
    t.datetime "created_at", null: false
    t.boolean "entered_hardcore", default: true, null: false
    t.integer "event_awareness"
    t.string "favourite_language"
    t.string "github_username"
    t.bigint "original_city_id"
    t.string "private_leaderboard"
    t.string "provider"
    t.bigint "referrer_id"
    t.datetime "remember_created_at"
    t.text "remember_token"
    t.integer "roles", default: 0, null: false
    t.string "slack_access_token"
    t.string "slack_id"
    t.string "slack_username"
    t.integer "squad_id"
    t.boolean "synced", default: false, null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "username"
    t.integer "years_of_service", default: 0
    t.index ["aoc_id"], name: "index_users_on_aoc_id", unique: true
    t.index ["batch_id"], name: "index_users_on_batch_id"
    t.index ["city_id"], name: "index_users_on_city_id"
    t.index ["original_city_id"], name: "index_users_on_original_city_id"
    t.index ["referrer_id"], name: "index_users_on_referrer_id"
  end

  add_foreign_key "achievements", "users"
  add_foreign_key "city_points", "cities"
  add_foreign_key "city_scores", "cities"
  add_foreign_key "completions", "users"
  add_foreign_key "insanity_points", "users"
  add_foreign_key "insanity_scores", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "reactions", "snippets"
  add_foreign_key "reactions", "users"
  add_foreign_key "snippets", "users"
  add_foreign_key "solo_points", "users"
  add_foreign_key "solo_scores", "users"
  add_foreign_key "squad_points", "squads"
  add_foreign_key "squad_scores", "squads"
  add_foreign_key "users", "batches"
  add_foreign_key "users", "cities"
  add_foreign_key "users", "cities", column: "original_city_id"
  add_foreign_key "users", "users", column: "referrer_id"
end
