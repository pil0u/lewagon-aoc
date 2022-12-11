# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      fast_refresh_completions: {
        cron: "every 3 minutes from midnight to 4 am",
        class: "InsertNewCompletionsJob"
      },
      refresh_completions: {
        cron: "every 10 minutes from 4 to 24",
        class: "InsertNewCompletionsJob"
      }
    }
  }
end
