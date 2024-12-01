# frozen_string_literal: true

module Scores
  class InsanityScores < CachedComputer
    def get
      cache(Cache::InsanityScore) { Ranks::InsanityScores.rank_and_number(compute) }
    end

    private

    def after_compute; end

    def cache_key
      @cache_key ||= [
        State.with_changes.maximum(:fetch_api_end),
        User.maximum(:updated_at),
        Aoc.latest_day
      ].join("-")
    end

    def compute
      default_points = User.insanity.pluck(:id).index_with { |_u| [] } # No points by default

      points = Scores::InsanityPoints.get
      points
        .group_by { |p| p[:user_id] }
        .reverse_merge(default_points)
        .filter_map do |user_id, user_points|
          total_score = user_points.sum { |point| point[:score] }
          day_score = user_points.select { |point| point[:day] == Aoc.latest_day }
                                 .sum { |point| point[:score] }

          { user_id:, score: total_score, current_day_score: day_score } if total_score > 0
        end
    end
  end
end
