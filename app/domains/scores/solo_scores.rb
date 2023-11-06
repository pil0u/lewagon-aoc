# frozen_string_literal: true

module Scores
  class SoloScores < CachedComputer
    def get
      cache(Cache::SoloScore) { Ranks::SoloScores.rank_and_number(compute) }
    end

    private

    def cache_key
      @cache_key ||= [
        State.with_changes.maximum(:fetch_api_end),
        User.maximum(:updated_at),
        Aoc.latest_day
      ].join("-")
    end

    def compute
      default_points = User.pluck(:id).index_with { |_u| [] } # No points by default

      points = Scores::SoloPoints.get
      points
        .group_by { |p| p[:user_id] }
        .reverse_merge(default_points)
        .map do |user_id, user_points|
          total_score = user_points.sum { |point| point[:score] }

          day_points = user_points.select { |point| point[:day] == Aoc.latest_day }
          day_score = day_points.sum { |point| point[:score] }

          { user_id:, score: total_score, current_day_score: day_score }
        end
    end
  end
end
