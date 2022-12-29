# frozen_string_literal: true

module Ranks
  class InsanityScores < Ranker
    def initialize(scores)
      super
      # Index for o(1) fetch later on
      @completions = Completion.where(user_id: scores.pluck(:user_id)).group_by(&:user_id)
    end

    def ranking_criterion(score)
      completions = @completions.fetch(score[:user_id], [])
      [
        score[:score],
        -completions.sum(&:duration)
      ]
    end
  end
end
