# frozen_string_literal: true

module Ranks
  class SoloScores < Ranker
    def initialize(scores)
      super
      # Index for o(1) fetch later on
      @users = User.where(id: scores.pluck(:user_id)).index_by(&:id)
      @completions = Completion.where(user_id: scores.pluck(:user_id)).group_by(&:user_id)
    end

    def ranking_criterion(score)
      completions = @completions.fetch(score[:user_id], [])
      [
        score[:score],
        # Priorizing the display of non-insanity players (since those have their own leaderboard)
        @users[score[:user_id]].entered_hardcore ? 0 : 1,
        completions.count { |c| c.duration < 24.hours },
        completions.count { |c| c.duration < 48.hours },
        -completions.sum(&:duration)
      ]
    end
  end
end
