# frozen_string_literal: true

require "aoc"
require "scores"

namespace :scores do
  desc "Main task to call from Heroku Scheduler"
  task update: %i[introduction refresh conclusion]

  desc "Update last_api_fetch_start"
  task introduction: :environment do
    state = State.first
    now = Time.now.utc

    state.update(last_api_fetch_start: now)
    Rails.logger.info "🤖 Scores update started at #{now}"
  end

  desc "Fetch completition timestamps from AoC API and insert them in scores table"
  task refresh: :environment do
    # TODO: Add some logic in case of multiple rooms
    room_ids = ENV["AOC_ROOMS"].split(",")

    room_id = room_ids.first.split("-").first
    json = Aoc.fetch_json(room_id)

    User.update_sync_status_from(json)
    Rails.logger.info "✔ Users sync status updated"

    scores = Aoc.to_scores_array(json)
    Scores.insert(scores)
    Rails.logger.info "✔ Individual scores updated"
  end

  desc "Update last_api_fetch_end"
  task conclusion: :environment do
    state = State.first
    now = Time.now.utc

    state.update(last_api_fetch_end: now)
    Rails.logger.info "🏁 Scores update finished at #{now}"
  end
end
