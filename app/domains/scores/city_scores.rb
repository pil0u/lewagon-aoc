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
        City.maximum(:updated_at),
        Aoc.latest_day,
      ].join("-")
    end

    RETURNED_ATTRIBUTES = %i[
      score city_id
      current_day_part_1_contributors current_day_part_2_contributors
    ].freeze

    def compute
      points = Scores::CityPoints.get

      city_users = points.group_by { |point| point[:city_id] }
      city_users.filter_map do |city_id, city_points|
        part1, part2 = city_points.select { |point| point[:day] == Aoc.latest_day }.sort_by { |point| point[:challenge] }

        {
          score: city_points.pluck(:score).sum.ceil,
          city_id:,
          current_day_part_1_contributors: part1&.fetch(:contributor_count) || 0,
          current_day_part_2_contributors: part2&.fetch(:contributor_count) || 0,
        }
      end
    end
  end
end
