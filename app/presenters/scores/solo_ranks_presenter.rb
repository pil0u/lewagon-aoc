module Scores
  class SoloRanksPresenter
    def initialize(scores)
      # storing with an index for o(1) fetch later
      @scores_per_user = scores.map { |u| [u[:user_id], u] }.to_h.freeze
    end

    attr_reader :scores_per_user

    def ranks
      @ranks ||= User
        .where(id: scores_per_user.keys)
        .includes(:city, :squad, :batch, :completions)
        .map { |user| { **identity_of(user), **stats_of(user) } }
        .sort_by { |user| user[:score] * -1 } # * -1 to reverse with no iterating
        .each_with_object({ collection: [], curr_score: -1, curr_rank: 0 }) do |user, ranks|
          ranks[:curr_rank] += 1 unless user[:score] == ranks[:curr_score] # handling equalities
          ranks[:collection] << user.merge(rank: ranks[:curr_rank])
          ranks[:curr_score] = user[:score]
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
        entered_hardcore: user.entered_hardcore,
      }
    end

    def stats_of(user, at = DateTime.now)
      completions = user.completions
      all = completions.actual.where(challenge: 1).count
      gold = completions.actual.where(challenge: 2).count
      silver = all - gold

      score = scores_per_user[user.id]
      {
        silver_stars: silver,
        gold_stars: gold,
        score: score[:score],
        # daily_score: 100 #TODO: Implement
      }
    end
  end
end
