# frozen_string_literal: true

module Ranks
  class SquadScores < Ranker
    def initialize(scores)
      super
      # Index for o(1) fetch later on
      @squads = Squad.where(id: scores.pluck(:squad_id)).includes(:completions).index_by(&:id)
    end

    def ranking_criterion(score)
      squad = @squads[score[:squad_id]]
      [
        squad.completions.count,
        -squad.users.count,
        score[:score]
      ]
    end
  end
end
