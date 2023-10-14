# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      refresh_completions: {
        cron: "*/10 * 1-30 11-12 *", # every 10th minute between November 1st and December 30th
        class: "InsertNewCompletionsJob"
      },
      auto_cleanup: {
        cron: "55 5 * * *", # every day at 5:55
        class: "Cache::CleanupJob"
      },
      lock_time_achievements: {
        cron: "30 18 9 12 *", # 9th December at 18:30
        class: "Achievements::LockTimeJob"
      },
      scrape_kitt: {
        cron: "0 5 1 12 *", # December 1st 5am
        class: "KittScraperJob"
      }
    }
  }
end
