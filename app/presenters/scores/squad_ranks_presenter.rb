module Scores
  class SquadRanksPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_squad = scores.map { |u| [u[:squad_id], u] }.to_h.freeze
    end

    attr_reader :scores_per_squad

    def ranks
      @ranks ||= Squad
        .where(id: scores_per_squad.keys)
        .includes(:users)
        .map { |squad| { **identity_of(squad), **stats_of(squad) } }
        .sort_by { |squad| squad[:score] * -1 } # * -1 to reverse with no iterating
        .each_with_object({ collection: [], curr_score: -1, curr_rank: 0 }) do |squad, ranks|
          ranks[:curr_rank] += 1 unless squad[:score] == ranks[:curr_score] # handling equalities
          ranks[:collection] << squad.merge(rank: ranks[:curr_rank])
          ranks[:curr_score] = squad[:score]
          # previous_rank: 12, #TODO: Clarify behavior and implement
        end[:collection]
    end

    def identity_of(squad)
      {
        id: squad.id,
        name: squad.name,
        total_members: squad.users.count,
      }
    end

    def stats_of(squad, at = DateTime.now)
      score = scores_per_squad[squad.id]
      {
        score: score[:score],
        # daily_score: 200      #TODO: Implement
      }
    end
  end
end
