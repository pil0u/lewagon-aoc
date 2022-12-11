# frozen_string_literal: true

module Scores
  class CityPoints < CachedComputer
    def get
      cache(Cache::CityPoint) { compute }
    end

    private

    def cache_key
      @cache_key ||= [
        State.maximum(:fetch_api_end),
        City.maximum(:updated_at)
      ].join("-")
    end

    RETURNED_ATTRIBUTES = %i[
      city_id day challenge
      score total_score contributor_count
    ].freeze

    def compute
      points = Scores::SoloPoints.get

      # index for o(1) fetch
      city_for_user = User.where(id: points.pluck(:user_id)).pluck(:id, :city_id).to_h
      city_users = points.group_by { |user| city_for_user[user[:user_id]] }

      city_users.without(nil).flat_map do |city_id, user_points|
        challenge_contribs = user_points.group_by { |point| [point[:day], point[:challenge]] }

        countable = top_contributors_of(city_id)
        challenge_contribs.map do |(day, challenge), contributions|
          countable_scores = contributions
                             .pluck(:score)
                             .sort_by { |score| score * -1 } # * -1 to reverse without another iteration
                             .slice(0, countable)

          # If countable_scores < countable_user_count, it behaves as if the
          # missing scores were 0
          avg = countable_scores.sum.to_f / countable

          {
            city_id:,
            day:,
            challenge:,
            score: avg,
            total_score: countable_scores.sum,
            contributor_count: contributions.count
          }
        end
      end
    end

    def top_contributors_of(city_id)
      @contributors ||= City.all.to_h { |city| [city.id, city.top_contributors] }
      @contributors[city_id]
    end
  end
end
