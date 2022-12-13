# frozen_string_literal: true

module Scores
  class SoloPoints < CachedComputer
    def get
      cache(Cache::SoloPoint) { compute }
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
      completions = Completion.select(Arel.sql("completions.*"), Arel.sql(<<~SQL.squish))
        CASE
        WHEN duration <= interval '24 hours'
          THEN 50
        WHEN duration <= '48 hours'
          THEN 50 - (EXTRACT(EPOCH FROM (duration - interval '1 day')) / 3600)::integer
        ELSE
          25
        END AS score
      SQL

      completions.map do |completion|
        completion.attributes.symbolize_keys
                  .slice(*RETURNED_ATTRIBUTES)
                  .merge(completion_id: completion.id)
      end
    end
  end
end
