# frozen_string_literal: true

module Ranks
  class CityScores < Ranker
    def initialize(scores)
      super
      # Index for o(1) fetch later on
      @cities = City.where(id: scores.pluck(:city_id)).includes(:completions).index_by(&:id)
    end

    def ranking_criterion(score)
      city = @cities[score[:city_id]]
      [
        score[:score],
        ratio_of_completions(city, under: 24.hours),
        ratio_of_completions(city, under: 48.hours),
      ]
    end

    def ratio_of_completions(city, under:)
      city.completions.group_by { |c| [c.day, c.challenge] }.sum do |_, completions|
        completions.count { |c| c.duration < under }.clamp(0, city.top_contributors).to_f
      end / city.top_contributors
    end
  end
end
