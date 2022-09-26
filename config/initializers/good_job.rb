# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    execution_mode: :async,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      refresh_completions: {
        cron: "every 10 minutes",
        class: "InsertNewCompletionsJob"
      }
    }
  }
end
