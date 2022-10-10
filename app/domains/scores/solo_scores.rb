module Scores
  class SoloScores < CachedComputer
    def get
      cache(Cache::SoloScore) { compute }
    end

    private

    def cache_key
      @key ||= State.order(:fetch_api_end).last.fetch_api_end
    end

    RETURNED_ATTRIBUTES = [:score, :user_id]

    def compute
      points = Scores::SoloPoints.get
      points
        .group_by { |p| p[:user_id] }
        .map do |user_id, user_points|
          total_score = user_points.sum { |u| u[:score] }
          { user_id: user_id, score: total_score  }
        end
    end
  end
end
