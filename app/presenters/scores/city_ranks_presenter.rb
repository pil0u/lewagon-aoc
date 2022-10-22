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
        .each_with_object({ collection: [], last_score: -1, rank: 0, gap: 0 }) do |city, ranks|
          if city[:score] == ranks[:last_score] # handling equalities
            ranks[:gap] += 1
          else
            ranks[:rank] += 1 + ranks[:gap]
            ranks[:gap] = 0
          end
          ranks[:collection] << city.merge(rank: ranks[:rank])
          # previous_rank: 12, #TODO: Clarify behavior and implement
          ranks[:last_score] = city[:score]
        end[:collection]
    end

    def identity_of(city)
      {
        id: city.id,
        name: city.name,
        slug: city.slug,
      }
    end

    def stats_of(city)
      score = scores_per_city[city.id] || { score: 0 }
      {
        score: score[:score],
        total_members: city.users.count,
        top_contributors: city.top_contributors
        # daily_score: 200      #TODO: Implement
        # daily_contributors_part_1: 23,  # TODO: Implement
        # daily_contributors_part_2: 23,  # TODO: Implement
      }
    end
  end
end
