# frozen_string_literal: true

module Scores
  class CityScores < CachedComputer
    def get
      cache(Cache::CityScore) { compute }
    end

    private

    def cache_key
      @cache_key ||= [
        State.order(:fetch_api_end).last.fetch_api_end,
        City.maximum(:updated_at),
      ].join("-")
    end

    RETURNED_ATTRIBUTES = %i[score city_id].freeze

    def compute
      points = Scores::SoloScores.get

      # index for o(1) fetch
      city_for_user = User.where(id: points.pluck(:user_id)).pluck(:id, :city_id).to_h
      cities = City.all.index_by(&:id)

      city_users = points.group_by { |user| city_for_user[user[:user_id]] }
      city_users.filter_map do |city_id, user_scores|
        next if city_id.nil?

        countable_user_count = cities[city_id].top_contributors

        countable_scores = user_scores.
          pluck(:score).
          sort_by { |score| score * -1 }. # * -1 to reverse without another iteration
          slice(0, countable_user_count)

        # If countable_scores < countable_user_count, it behaves as if the
        # missing scores were 0
        average_score = countable_scores.sum.to_f / countable_user_count

        { city_id:, score: average_score.ceil }
      end
    end
  end
end
