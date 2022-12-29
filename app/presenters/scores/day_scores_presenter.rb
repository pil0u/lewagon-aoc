# frozen_string_literal: true

module Scores
  class DayScoresPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_user = scores.group_by { |u| u[:user_id] }.freeze
    end

    attr_reader :scores_per_user

    def scores
      @scores ||= User
                  .includes(:completions)
                  .where(id: scores_per_user.keys)
                  .flat_map { |user| @scores_per_user[user.id].map { |score| present(user, score) } }
                  # * -1 to revert the sort without new iterations
                  .sort_by { |user| [user[:day], user[:score] * -1, user[:part_2], user[:part_1]].compact }
    end

    def present(user, score)
      { **identity_of(user), **stats_of(user, score) }
    end

    def identity_of(user)
      {
        uid: user.uid,
        username: user.username
      }
    end

    def stats_of(user, score)
      {
        day: score[:day],
        score: score[:score],
        part_1: user.completions.find { |completion| completion.id == score[:part_1_completion_id] }&.duration,
        part_2: user.completions.find { |completion| completion.id == score[:part_2_completion_id] }&.duration
      }
    end
  end
end
