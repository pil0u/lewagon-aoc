# frozen_string_literal: true

module Scores
  class SquadRanksPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_squad = scores.index_by { |u| u[:squad_id] }.freeze
    end

    attr_reader :scores_per_squad

    def ranks
      @ranks ||= Squad
                 .includes(:users)
                 .map { |squad| { **identity_of(squad), **stats_of(squad) } }
                 .sort_by { |squad| squad[:score] * -1 } # * -1 to reverse with no iterating
                 .each_with_object({ collection: [], last_score: -1, rank: 0, gap: 0 }) do |squad, ranks|
                   if squad[:score] == ranks[:last_score] # handling equalities
                     ranks[:gap] += 1
                   else
                     ranks[:rank] += 1 + ranks[:gap]
                     ranks[:gap] = 0
                   end
                   ranks[:collection] << squad.merge(rank: ranks[:rank])
                   ranks[:last_score] = squad[:score]
                   # previous_rank: 12, #TODO: Clarify behavior and implement
                 end[:collection]
    end

    def identity_of(squad)
      {
        id: squad.id,
        name: squad.name
      }
    end

    def stats_of(squad)
      score = scores_per_squad[squad.id] || { score: 0 }
      {
        score: score[:score],
        daily_score: score[:current_day_score],
        total_members: squad.users.size
      }
    end
  end
end
