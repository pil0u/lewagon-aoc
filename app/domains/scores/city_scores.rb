# frozen_string_literal: true

module Scores
  class CityScores < CachedComputer
    def get
      cache(Cache::CityScore) { Ranks::CityScores.rank_and_number(compute) }
    end

    private

    def cache_key
      @cache_key ||= [
        State.with_changes.maximum(:fetch_api_end),
        City.maximum(:updated_at),
        Aoc.latest_day
      ].join("-")
    end

    RETURNED_ATTRIBUTES = %i[
      rank score city_id
      current_day_part_1_contributors current_day_part_2_contributors
    ].freeze

    def compute
      points = Scores::CityPoints.get

      city_users = points.group_by { |point| point[:city_id] }
      city_users.filter_map do |city_id, city_points|
        contributors = city_points
                       .select { |point| point[:day] == Aoc.latest_day }
                       .to_h { |part| [part[:challenge], part[:contributor_count]] }

        {
          score: city_points.pluck(:score).sum.ceil,
          city_id:,
          current_day_part_1_contributors: contributors[1] || 0,
          current_day_part_2_contributors: contributors[2] || 0
        }
      end
    end
  end
end
