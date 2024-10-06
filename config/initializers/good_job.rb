# frozen_string_literal: true

require "aoc"

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      refresh_completions: {                      # every 10 minutes between November 1st and December 30th
        cron: "*/10 * 1-30 11-12 *",
        class: "InsertNewCompletionsJob"
      },
      auto_cleanup: {                             # every puzzle day, just before a new puzzle is released
        cron: "55 23 1-25 12 * America/New_York",
        class: "Cache::CleanupJob"
      },
      generate_buddies: {                         # every puzzle day, just after a new puzzle is released
        cron: "5 0 1-25 12 * America/New_York",
        class: "Buddies::GenerateDailyPairsJob",
        args: -> { [Aoc.latest_day] }
      },
      generate_slack_thread: {                    # every puzzle day, just after a new puzzle
        cron: "5 0 1-25 12 * America/New_York",
        class: "GenerateSlackThread",
        args: -> { [Time.current] }
      },
      unlock_lock_time_achievements: {            # once at lock time
        cron: "30 17 8 12 * Europe/Paris",
        class: "Achievements::LockTimeJob"
      }
    }
  }
end
