# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      refresh_completions: {
        cron: "*/10 * 1-30 11-12 *", # every 10 minutes between November 1st and December 30th
        class: "InsertNewCompletionsJob"
      },
      auto_cleanup: {
        cron: "55 23 * * * on America/New_York", # every day before a new puzzle
        class: "Cache::CleanupJob"
      },
      lock_time_achievements: {
        cron: "30 17 8 12 * Europe/Paris", # on lock tim
        class: "Achievements::LockTimeJob"
      }
    }
  }
end
