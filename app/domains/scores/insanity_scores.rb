# frozen_string_literal: true

module Scores
  class InsanityScores < CachedComputer
    def get
      cache(Cache::InsanityScore) { compute }
    end

    private

    def after_compute
      # Achievements::MassUnlockJob.perform_later(:raising_the_bar)
    end

    def cache_key
      @cache_key ||= [
        State.maximum(:fetch_api_end),
        User.maximum(:updated_at),
        Aoc.latest_day
      ].join("-")
    end

    RETURNED_ATTRIBUTES = %i[score user_id current_day_score].freeze

    def compute
      default_points = User.insanity.pluck(:id).index_with { |_u| [] } # No points by default

      points = Scores::InsanityPoints.get
      points
        .group_by { |p| p[:user_id] }
        .reverse_merge(default_points)
        .map do |user_id, user_points|
          total_score = user_points.sum { |u| u[:score] }
          day_score = user_points.find { |points| points[:day] == Aoc.latest_day } || {}
          { user_id:, score: total_score, current_day_score: day_score.fetch(:score, 0) }
        end
    end
  end
end
