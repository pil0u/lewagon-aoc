# frozen_string_literal: true

module Ranks
  class CityScores < Ranker
    def initialize(scores)
      super
      # Index for o(1) fetch later on
      @cities = City.where(id: scores.pluck(:city_id)).index_by(&:id)
    end

    def order
      @scores.sort_by { |score| criterion(score) }.reverse
    end

    def criterion(score)
      city = @cities[score[:city_id]]
      [
        score[:score],
        [city.top_contributors, city.completions.where('duration < ?', 24.hours).count].min,
        [city.top_contributors, city.completions.where('duration < ?', 48.hours).count].min,
      ]
    end
  end
end
