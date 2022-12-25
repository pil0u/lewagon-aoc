# frozen_string_literal: true

module Scores
  class CityScoresPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_city = scores.index_by { |u| u[:city_id] }.freeze
    end

    attr_reader :scores_per_city

    def ranks
      @ranks ||= City
                 .includes(:users)
                 .map { |city| { **identity_of(city), **stats_of(city) } }
                 .sort_by { |city| city[:order] || Float::INFINITY }
    end

    def identity_of(city)
      {
        id: city.id,
        name: city.name,
        slug: city.slug
      }
    end

    DEFAULTS = { score: 0, current_day_part_1_contributors: 0, current_day_part_2_contributors: 0 }.freeze
    def stats_of(city)
      score = scores_per_city[city.id] || DEFAULTS.merge(rank: scores_per_city.count + 1)
      {
        rank: score[:rank],
        order: score[:order],
        score: score[:score],
        total_members: city.users.size,
        top_contributors: city.top_contributors,
        daily_contributors_part_1: score[:current_day_part_1_contributors],
        daily_contributors_part_2: score[:current_day_part_2_contributors]
      }
    end
  end
end
