# frozen_string_literal: true

module Ranks
  class SquadScores < Ranker
    def initialize(scores)
      super
      # Index for o(1) fetch later on
      @squads = Squad.where(id: scores.pluck(:squad_id)).includes(:completions).index_by(&:id)
    end

    def rank
      @scores.sort_by { |score| criterion(score) }.reverse
    end

    def criterion(score)
      squad = @squads[score[:squad_id]]
      [
        score[:score],
        squad.completions.count { |c| c.duration < 24.hours },
        squad.completions.count { |c| c.duration < 48.hours },
      ]
    end
  end
end
