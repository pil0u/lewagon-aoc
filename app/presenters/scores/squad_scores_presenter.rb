# frozen_string_literal: true

module Scores
  class SquadScoresPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_squad = scores.index_by { |u| u[:squad_id] }.freeze
    end

    attr_reader :scores_per_squad

    def get
      @scores ||= Squad # rubocop:disable Naming/MemoizedInstanceVariableName
                  .includes(:users)
                  .map { |squad| { **identity_of(squad), **stats_of(squad) } }
                  .sort_by { |squad| squad[:order] || Float::INFINITY }
    end

    def identity_of(squad)
      {
        id: squad.id,
        name: squad.name
      }
    end

    def stats_of(squad)
      score = scores_per_squad[squad.id] || { score: 0, current_day_score: 0, rank: scores_per_squad.count + 1 }
      {
        rank: score[:rank],
        order: score[:order],
        score: score[:score],
        daily_score: score[:current_day_score],
        total_members: squad.users.size
      }
    end
  end
end
