# frozen_string_literal: true

require "aoc"
require "help"

namespace :scores do
  desc "Main task to call from Heroku Scheduler"
  task update: %i[introduction refresh compute_ranks compute_scores conclusion]

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
    Score.replace_all(scores)
    Rails.logger.info "✔ Individual timestamps updated"
  end

  desc "Compute individual rank, rank within batch & rank within city for each score"
  task compute_ranks: :environment do
    Score.compute_ranks
    Rails.logger.info "✔ Ranks computed"
  end

  desc "Compute scores for each level of granularity"
  task compute_scores: :environment do
    # Use the same ranking system as AoC for individual scores, except that it will
    # gather _all_ players if there are more than 1 AoC room
    max_solo_score = User.count
    Rails.logger.info "Maximum score_solo: #{max_solo_score}"
    Score.update_all("score_solo = #{max_solo_score} - rank_solo + 1")
    Rails.logger.info "✔ Individual scores computed"

    # To build scores for batches and cities, we considered that:
    # 1. A larger city or larger batch should not have too big an advantage
    #    => Limit the number of awarded players per batch
    # 2. All players should be encouraged to take part in the contest
    #    => Award points even if you are not the very first to solve a puzzle
    # 3. Incentivize groups to bring more players in
    #
    # Solution: take the median number of players by batch (or by city) as the maximum score and
    # we use the same formula as the individual score.

    max_batch_score = Help.median(User.group(:batch_id).count.values)
    Rails.logger.info "Maximum score_in_batch: #{max_batch_score}"
    Score.update_all("score_in_batch = greatest(#{max_batch_score} - rank_in_batch + 1, 0)")
    Rails.logger.info "✔ Batch scores computed"

    max_city_score = Help.median(User.group(:city_id).count.values)
    Rails.logger.info "Maximum score_in_city: #{max_city_score}"
    Score.update_all("score_in_city = greatest(#{max_city_score} - rank_in_city + 1, 0)")
    Rails.logger.info "✔ City scores computed"
  end

  desc "Update last_api_fetch_end"
  task conclusion: :environment do
    state = State.first
    now = Time.now.utc

    state.update(last_api_fetch_end: now)
    Rails.logger.info "🏁 Scores update finished at #{now}"
  end
end
