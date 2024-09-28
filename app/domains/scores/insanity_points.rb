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

    def compute
      completions = Completion
                    .joins(:user).merge(User.insanity)
                    .select(Arel.sql("completions.*"), Arel.sql(<<~SQL.squish))
                      CASE
                        WHEN rank() OVER (PARTITION BY day, challenge ORDER BY completion_unix_time ASC) <= 5 THEN
                          6 - rank() OVER (PARTITION BY day, challenge ORDER BY completion_unix_time ASC)
                        ELSE 0
                      END AS score
                    SQL

      completions.map do |completion|
        completion.attributes.symbolize_keys
                  .slice(:score, :user_id, :day, :challenge)
                  .merge(completion_id: completion.id)
      end
    end
  end
end
