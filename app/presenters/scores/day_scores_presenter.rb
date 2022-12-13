# frozen_string_literal: true

module Scores
  class DayScoresPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_user = scores.index_by { |u| u[:user_id] }.freeze
    end

    attr_reader :scores_per_user

    def scores
      @ranks ||= User
                 .includes(:completions)
                 .where(id: scores_per_user.keys)
                 .map { |user| { **identity_of(user), **stats_of(user) } }
                 # * -1 to revert the sort without new iterations
                 .sort_by { |user| [user[:score] * -1, user[:part_2], user[:part_1]].compact }
    end

    def identity_of(user)
      {
        username: user.username,
      }
    end

    def stats_of(user)
      score = scores_per_user[user.id]
      {
        day: score[:day],
        score: score[:score],
        part_1: user.completions.find { |completion| completion.id == score[:part_1_completion_id] }&.duration,
        part_2: user.completions.find { |completion| completion.id == score[:part_2_completion_id] }&.duration
      }
    end
  end
end
