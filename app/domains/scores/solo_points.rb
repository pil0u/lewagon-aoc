module Scores
  class SoloPoints < CachedComputer
    def get
      cache(Cache::SoloPoint) { compute }
    end

    private

    def cache_key
      @key ||= State.order(:fetch_api_end).last.fetch_api_end
    end

    RETURNED_ATTRIBUTES = [:score, :user_id, :day, :challenge]

    def compute
      completions = Completion.select(Arel.star, Arel.sql(<<~SQL))
        CASE
        WHEN duration <= interval '24 hours'
          THEN 50
        WHEN duration <= '48 hours'
          THEN 50 - (EXTRACT(EPOCH FROM (duration - interval '1 day')) / 3600)::integer
        ELSE
          25
        END AS score
      SQL

      completions.map { |c| c.attributes.symbolize_keys.slice(*RETURNED_ATTRIBUTES) }
    end
  end
end
