# frozen_string_literal: true

module Scores
  class CityScores < CachedComputer
    def get
      cache(Cache::CityScore) { compute }
    end

    private

    def cache_key
      @cache_key ||= [
        State.maximum(:fetch_api_end),
        City.maximum(:updated_at)
      ].join("-")
    end

    RETURNED_ATTRIBUTES = %i[
      score city_id current_day_score
      current_day_part_1_contributors current_day_part_2_contributors
    ].freeze

    def compute
      points = Scores::SoloPoints.get

      # index for o(1) fetch
      city_for_user = User.where(id: points.pluck(:user_id)).pluck(:id, :city_id).to_h

      city_users = points.group_by { |user| city_for_user[user[:user_id]] }
      city_users.filter_map do |city_id, user_points|
        compute_score(city_id, user_points)
      end
    end
  end

  def compute_score(city_id, user_points)
    return if city_id.nil?

    countable_user_count = cities[city_id].top_contributors

    per_challenge = user_points.group_by { |points| [points[:day], points[:challenge]] }
    per_challenge = per_challenge.map do |challenge, contributions|
      score = compute_challenge_score(challenge, contributions)

      # If countable_scores < countable_user_count, it behaves as if the
      # missing scores were 0
      score[:average_score] = score[:total_score].to_f / countable_user_count

      score
    end

    total_score = per_chall.pluck(:average_score).sum
    current_day = per_chall.select { |point| point[:day] == Aoc.latest_day }
    part_1 = current_day.find { |point| point[:challenge] == 1 } || {}
    part_2 = current_day.find { |point| point[:challenge] == 2 } || {}

    {
      city_id:,
      score: total_score.ceil,
      current_day_part_1_contributors: part_1[:contributors]&.count || 0,
      current_day_part_2_contributors: part_2[:contributors]&.count || 0,
      current_day_score: current_day.pluck(:average_score).sum
    }
  end

  def compute_challenge_score(challenge, contributions)
    countable_scores = contributions
      .pluck(:score)
      .sort_by { |score| score * -1 } # * -1 to reverse without another iteration
      .slice(0, countable_user_count)

    { day: day, challenge: challenge, total_score: countable_scores.sum, contributors: points.pluck(:user_id) }
  end
end
