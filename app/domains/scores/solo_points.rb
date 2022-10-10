module Scores
  class SoloPoints
    def self.get
      new.get
    end

    def get
      cache { compute }
    end

    private

    def last_aoc_sync
      @key ||= State.order(:last_api_fetch_end).last.last_api_fetch_end
    end

    ATTRIBUTES = [:score, :user_id, :day, :challenge]

    def cache
      points = Cache::SoloPoint.where(fetched_at: last_aoc_sync)
      if points.any?
        return points.pluck(*ATTRIBUTES).map { |p| ATTRIBUTES.zip(p).to_h }
      else
        points = yield
        Cache::SoloPoint.insert_all(
          points.map do |attributes|
            attributes.merge(fetched_at: last_aoc_sync)
          end
        )
        return points
      end
    end

    def compute
      ActiveRecord::Base.transaction do
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

        completions.map { |c| c.attributes.symbolize_keys.slice(*ATTRIBUTES) }
      end
    end
  end
end
