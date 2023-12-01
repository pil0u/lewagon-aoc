# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      refresh_completions: { # every 10 minutes between November 1st and December 30th
        cron: "*/10 * 1-30 11-12 *",
        class: "InsertNewCompletionsJob"
      },
      auto_cleanup: { # every day before a new puzzle
        cron: "55 23 * * * on America/New_York",
        class: "Cache::CleanupJob"
      },
      unlock_lock_time_achievements: {
        cron: "30 17 8 12 * Europe/Paris",
        class: "Achievements::LockTimeJob"
      }
    }
  }
end
