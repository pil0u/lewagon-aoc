module Scores
  class CityScores < CachedComputer
    def get
      cache(Cache::CityScore) { compute }
    end

    private

    def cache_key
      @key ||= [
        State.order(:fetch_api_end).last.fetch_api_end,
        City.maximum(:updated_at)
      ].join('-')
    end

    RETURNED_ATTRIBUTES = [:score, :city_id]

    def compute
      points = Scores::SoloScores.get

      # index for o(1) fetch
      city_for_user = User.where(id: points.pluck(:user_id)).pluck(:id, :city_id).to_h
      city_sizes = City.pluck(:id, :size).to_h

      cities = points.group_by { |user| city_for_user[user[:user_id]] }
      cities.map do |city_id, user_scores|
        next if city_id.nil?
        three_percents = (city_sizes[city_id] * 0.03).ceil
        countable_user_count = [three_percents, 10].max

        countable_scores = user_scores
          .map { |user| user[:score] }
          .sort
          .reverse[0...countable_user_count]

        { city_id: city_id, score: countable_scores.sum }
      end.compact
    end
  end
end
