# frozen_string_literal: true

module Scores
  class InsanityPoints < CachedComputer
    def get
      cache(Cache::InsanityPoint) { compute }
    end

    private

    RETURNED_ATTRIBUTES = %i[score user_id day challenge].freeze

    def compute
      completions = Completion
                    .joins(:user).merge(User.insanity)
                    .select(Arel.star, Arel.sql(<<~SQL.squish))
                      (SELECT COUNT(*) FROM users WHERE entered_hardcore AND synced)
                      - (rank() OVER (PARTITION BY day, challenge ORDER BY completion_unix_time ASC))
                      + 1
                      AS score
                    SQL

      completions.map { |c| c.attributes.symbolize_keys.slice(*RETURNED_ATTRIBUTES) }
    end
  end
end
