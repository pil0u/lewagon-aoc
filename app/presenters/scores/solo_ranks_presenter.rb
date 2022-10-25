# frozen_string_literal: true

module Scores
  class SoloRanksPresenter
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
                 .sort_by { |user| user[:score] * -1 } # * -1 to reverse with no iterating
                 .each_with_object({ collection: [], last_score: -1, rank: 0, gap: 0 }) do |user, ranks|
                   if user[:score] == ranks[:last_score] # handling equalities
                     ranks[:gap] += 1
                   else
                     ranks[:rank] += 1 + ranks[:gap]
                     ranks[:gap] = 0
                   end
                   ranks[:collection] << user.merge(rank: ranks[:rank])
                   ranks[:last_score] = user[:score]
                   # previous_rank: 12, #TODO: Clarify behavior and implement
                 end[:collection]
    end

    def identity_of(user)
      {
        uid: user.id,
        username: user.username,
        city_name: user.city&.name,
        batch_number: user.batch&.number,
        squad_name: user.squad&.name,
        entered_hardcore: user.entered_hardcore
      }
    end

    def stats_of(user)
      completions = user.completions.group_by(&:challenge).transform_values(&:count)
      all, gold = completions[1] || 0, completions[2] || 0
      silver = all - gold

      score = scores_per_user[user.id]
      {
        silver_stars: silver,
        gold_stars: gold,
        score: score[:score]
        # daily_score: 100 #TODO: Implement
      }
    end
  end
end
