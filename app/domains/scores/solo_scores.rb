module Scores
  class SoloScores
    def self.get
      new.get
    end

    def get
      cache { compute }
    end

    private

    def last_aoc_sync
      @key ||= State.order(:last_api_fetch_end).last.last_api_fetch_end
    end

    ATTRIBUTES = [:score, :user_id]

    def cache
      points = Cache::SoloScore.where(fetched_at: last_aoc_sync)
      if points.any?
        return points.pluck(*ATTRIBUTES).map { |p| ATTRIBUTES.zip(p).to_h }
      else
        points = yield
        Cache::SoloScore.insert_all(
          points.map do |attributes|
            attributes.merge(fetched_at: last_aoc_sync)
          end
        )
        return points
      end
    end

    def compute
      ActiveRecord::Base.transaction do
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
end
