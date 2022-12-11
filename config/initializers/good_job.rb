# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      refresh_completions: {
        cron: "every 10 minutes",
        class: "InsertNewCompletionsJob"
      },
      auto_cleanup: {
        cron: "every day at 1 am",
        class: "InsertNewCompletionsJob"
      }
    }
  }
end
