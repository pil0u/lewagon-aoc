# frozen_string_literal: true

module Scores
  class DayScoresPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_user = scores.group_by { |u| u[:user_id] }.freeze
    end

    attr_reader :scores_per_user

    def get
      @scores ||= User # rubocop:disable Naming/MemoizedInstanceVariableName
                  .includes(:completions)
                  .where(id: scores_per_user.keys)
                  .flat_map { |user| @scores_per_user[user.id].map { |score| present(user, score) } }
                  .sort_by { |user| user[:order] }
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
        rank: score[:rank],
        order: score[:order],
        day: score[:day],
        score: score[:score],
        part_1: user.completions.find { |completion| completion.id == score[:part_1_completion_id] }&.duration,
        part_2: user.completions.find { |completion| completion.id == score[:part_2_completion_id] }&.duration
      }
    end
  end
end
