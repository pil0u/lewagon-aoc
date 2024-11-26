# frozen_string_literal: true

require "aoc"

Rails.application.configure do
  config.good_job = {
    execution_mode: :external,
    max_threads: 5,
    shutdown_timeout: 30,
    enable_cron: true,
    cron: {
      # every 10 minutes between November 1st and December 30th
      insert_new_completions: {
        cron: "*/10 * 1-30 11-12 *",
        class: "InsertNewCompletionsJob"
      },
      # every puzzle day, 5 minutes before a new puzzle is released
      cache_cleanup: {
        cron: "55 23 1-25 12 * America/New_York",
        class: "Cache::CleanupJob"
      },
      # every puzzle day, 1 minutes after a new puzzle is released
      generate_slack_thread: {
        cron: "1 0 1-25 12 * America/New_York",
        class: "GenerateSlackThread",
        args: -> { [Time.current] }
      },
      # every puzzle day, 5 minutes after a new puzzle is released
      buddies_generate_daily_pairs: {
        cron: "5 0 1-25 12 * America/New_York",
        class: "Buddies::GenerateDailyPairsJob",
        args: -> { [Aoc.latest_day] }
      },
      # every puzzle day, every 5 minutes for 3 hours after a new puzzle is released
      update_puzzles_difficulty: {
        cron: "*/5 0-2 1-25 12 * America/New_York",
        class: "UpdatePuzzlesDifficultyJob"
      }
    }
  }
end
