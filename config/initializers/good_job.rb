# frozen_string_literal: true

require "aoc"

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      insert_new_completions: {                   # every 10 minutes between November 1st and December 30th
        cron: "*/10 * 1-30 11-12 *",
        class: "InsertNewCompletionsJob"
      },
      cache_cleanup: {                            # every puzzle day, just before a new puzzle
        cron: "55 23 1-25 12 * America/New_York",
        class: "Cache::CleanupJob"
      },
      buddies_generate_daily_pairs: {             # every puzzle day, just after a new puzzle
        cron: "5 0 1-25 12 * America/New_York",
        class: "Buddies::GenerateDailyPairsJob",
        args: -> { [Aoc.latest_day] }
      },
      achievements_lock_time: {                   # once at lock time
        cron: "30 17 8 12 * Europe/Paris",
        class: "Achievements::LockTimeJob"
      }
    }
  }
end
