# frozen_string_literal: true

module Scores
  class UserScoresPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_user = scores.index_by { |u| u[:user_id] }.freeze
    end

    attr_reader :scores_per_user

    def ranks
      @ranks ||= User
                 .where(id: scores_per_user.keys)
                 .includes(:city, :squad, :batch, :completions)
                 .map { |user| { **identity_of(user), **stats_of(user) } }
                 .sort_by { |user| user[:order] || Float::INFINITY }
    end

    def identity_of(user)
      {
        uid: user.uid.to_i,
        username: user.username,
        city_name: user.city&.name,
        batch_number: user.batch&.number,
        squad_name: user.squad&.name,
        entered_hardcore: user.entered_hardcore,
        created_at: user.created_at
      }
    end

    def stats_of(user)
      completions = user.completions.group_by(&:challenge).transform_values(&:count)
      all = completions[1] || 0
      gold = completions[2] || 0
      silver = all - gold

      score = scores_per_user[user.id]
      {
        rank: score[:rank],
        order: score[:order],
        silver_stars: silver,
        gold_stars: gold,
        score: score[:score],
        daily_score: score[:current_day_score]
      }
    end
  end
end
