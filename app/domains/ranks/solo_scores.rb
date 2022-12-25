# frozen_string_literal: true

module Ranks
  class SoloScores < Ranker
    def initialize(scores)
      super
      # Index for o(1) fetch later on
      @completions = Completion.where(user_id: scores.pluck(:user_id)).group_by(&:user_id)
    end

    def rank
      @scores.sort_by { |score| criterion(score) }.reverse
    end

    def criterion(score)
      completions = @completions.fetch(score[:user_id], [])
      [
        score[:score],
        completions.count { |c| c.duration < 24.hours },
        completions.count { |c| c.duration < 48.hours },
      ]
    end
  end
end
