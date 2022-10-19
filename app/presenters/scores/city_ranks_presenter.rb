module Scores
  class CityRanksPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_city = scores.map { |u| [u[:city_id], u] }.to_h.freeze
    end

    attr_reader :scores_per_city

    def ranks
      @ranks ||= City
        .includes(:users)
        .map { |city| { **identity_of(city), **stats_of(city) } }
        .sort_by { |city| city[:score] * -1 } # * -1 to reverse with no iterating
        .each_with_object({ collection: [], curr_score: -1, curr_rank: 0 }) do |city, ranks|
          ranks[:curr_rank] += 1 unless city[:score] == ranks[:curr_score] # handling equalities
          ranks[:collection] << city.merge(rank: ranks[:curr_rank])
          ranks[:curr_score] = city[:score]
          # previous_rank: 12, #TODO: Clarify behavior and implement
        end[:collection]
    end

    def identity_of(city)
      {
        id: city.id,
        name: city.name,
        slug: city.slug,
        total_members: city.users.count,
      }
    end

    def stats_of(city)
      score = scores_per_city[city.id] || { score: 0 }
      {
        score: score[:score],
        top_contributors: city.top_contributors
        # daily_score: 200      #TODO: Implement
        # daily_contributors_part_1: 23,  # TODO: Implement
        # daily_contributors_part_2: 23,  # TODO: Implement
      }
    end
  end
end
