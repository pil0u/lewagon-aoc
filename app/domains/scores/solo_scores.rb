# frozen_string_literal: true

module Scores
  class SoloScores < CachedComputer
    def get
      cache(Cache::SoloScore) { compute }
    end

    private

    def cache_key
      @cache_key ||= State.order(:fetch_api_end).last.fetch_api_end
    end

    RETURNED_ATTRIBUTES = %i[score user_id].freeze

    def compute
      default_points = User.pluck(:id).map { |u| [u, []] }.to_h # No points by default

      points = Scores::SoloPoints.get
      points
        .group_by { |p| p[:user_id] }
        .reverse_merge(default_points)
        .map do |user_id, user_points|
          total_score = user_points.sum { |u| u[:score] }
          { user_id:, score: total_score }
        end
    end
  end
end
