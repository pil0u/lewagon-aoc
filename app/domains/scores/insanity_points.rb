# frozen_string_literal: true

module Scores
  class InsanityPoints < CachedComputer
    def get
      cache(Cache::InsanityPoint) { compute }
    end

    private

    def cache_key
      @cache_key ||= [
        State.with_changes.maximum(:fetch_api_end),
        User.maximum(:updated_at)
      ].join("-")
    end

    RETURNED_ATTRIBUTES = %i[score user_id day challenge completion_id].freeze

    def compute
      completions = Completion
                    .joins(:user).merge(User.insanity)
                    .select(Arel.sql("completions.*"), Arel.sql(<<~SQL.squish))
                      (SELECT COUNT(*) FROM users WHERE entered_hardcore AND synced)
                      - (rank() OVER (PARTITION BY day, challenge ORDER BY completion_unix_time ASC))
                      + 1
                      AS score
                    SQL

      completions.map do |completion|
        completion.attributes.symbolize_keys
                  .slice(*RETURNED_ATTRIBUTES)
                  .merge(completion_id: completion.id)
      end
    end
  end
end
