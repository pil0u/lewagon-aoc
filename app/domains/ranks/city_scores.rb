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
        city.completions.count { |c| c.duration < 24.hours }.clamp(0, city.top_contributors),
        city.completions.count { |c| c.duration < 48.hours }.clamp(0, city.top_contributors),
      ]
    end
  end
end
