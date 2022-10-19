module Scores
  class SquadScores < CachedComputer
    def get
      cache(Cache::SquadScore) { compute }
    end

    private

    def cache_key
      @key ||= [
        State.order(:fetch_api_end).last.fetch_api_end,
        Squad.maximum(:updated_at)
      ].join('-')
    end

    RETURNED_ATTRIBUTES = [:score, :squad_id]

    def compute
      points = Scores::SquadPoints.get
      points
        .group_by { |p| p[:squad_id] }
        .map do |squad_id, squad_points|
          next if squad_id.nil?
          total_score = squad_points.sum { |u| u[:score] }
          { squad_id: squad_id, score: total_score  }
        end.compact
    end
  end
end
