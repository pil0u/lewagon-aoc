# frozen_string_literal: true

module Scores
  class SquadScores < CachedComputer
    def get
      cache(Cache::SquadScore) { compute }
    end

    private

    def cache_key
      @cache_key ||= [
        State.maximum(:fetch_api_end),
        Squad.maximum(:updated_at),
        Aoc.latest_day
      ].join("-")
    end

    RETURNED_ATTRIBUTES = %i[score squad_id current_day_score].freeze

    def compute
      points = Scores::SquadPoints.get
      points
        .group_by { |p| p[:squad_id] }
        .filter_map do |squad_id, squad_points|
          next if squad_id.nil?

          total_score = squad_points.sum { |points| points[:score] }
          day_score = squad_points.find { |points| points[:day] == Aoc.latest_day } || {}
          { squad_id:, score: total_score, current_day_score: day_score.fetch(:score, 0) }
        end
    end
  end
end
