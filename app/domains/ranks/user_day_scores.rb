# frozen_string_literal: true

module Ranks
  class UserDayScores < Ranker
    def initialize(scores)
      super
      # Index for o(1) fetch later on
      @completions = Completion.where(user_id: scores.pluck(:user_id)).group_by(&:user_id)
    end

    def ranking_criterion(score)
      completions = @completions.fetch(score[:user_id], [])
      [
        score[:score],
        -(completions.find { |c| c.id == score[:part_1_completion_id] }&.duration || Float::INFINITY),
        -(completions.find { |c| c.id == score[:part_2_completion_id] }&.duration || Float::INFINITY)
      ].compact
    end
  end
end
