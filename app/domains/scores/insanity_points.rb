# frozen_string_literal: true

module Scores
  class InsanityPoints < CachedComputer
    def get
      cache(Cache::InsanityPoint) { compute }
    end

    private

    def cache_key
      @cache_key ||= State.order(:fetch_api_end).last.fetch_api_end
    end

    RETURNED_ATTRIBUTES = %i[score user_id day challenge].freeze

    def compute
      completions = Completion.
        joins(:user).merge(User.where(entered_hardcore: true)).
        select(Arel.star, Arel.sql(<<~SQL))
          -- Nb of participating users
          (SELECT COUNT(*) FROM users WHERE entered_hardcore AND synced)
          -- - 1 for each person having completed it earlier
          - (rank() OVER (PARTITION BY day, challenge ORDER BY completion_unix_time ASC))
          + 1 -- 1-indexing
          AS score
      SQL

      completions.map { |c| c.attributes.symbolize_keys.slice(*RETURNED_ATTRIBUTES) }
    end
  end
end
