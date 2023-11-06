# frozen_string_literal: true

module Scores
  class SquadScores < CachedComputer
    def get
      cache(Cache::SquadScore) { Ranks::SquadScores.rank_and_number(compute) }
    end

    private

    def cache_key
      @cache_key ||= [
        State.with_changes.maximum(:fetch_api_end),
        Squad.maximum(:updated_at),
        Aoc.latest_day
      ].join("-")
    end

    def compute
      points = Scores::SquadPoints.get
      points
        .group_by { |p| p[:squad_id] }
        .filter_map do |squad_id, squad_points|
          next if squad_id.nil?

          total_score = squad_points.sum { |point| point[:score] }

          day_points = squad_points.select { |point| point[:day] == Aoc.latest_day }
          day_score = day_points.sum { |point| point[:score] }

          { squad_id:, score: total_score, current_day_score: day_score }
        end
    end
  end
end
