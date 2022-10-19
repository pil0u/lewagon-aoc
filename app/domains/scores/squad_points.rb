module Scores
  class SquadPoints < CachedComputer
    def get
      cache(Cache::SquadPoint) { compute }
    end

    private

    def cache_key
      @key ||= [
        State.order(:fetch_api_end).last.fetch_api_end,
        Squad.maximum(:updated_at)
      ].join('-')
    end

    RETURNED_ATTRIBUTES = [:score, :squad_id, :day, :challenge]

    def compute
      points = Scores::SoloPoints.get

      # index for o(1) fetch
      squad_for_user = User.where(id: points.pluck(:user_id)).pluck(:id, :squad_id).to_h

      points.each_with_object(Hash.new(0)) do |point, squad_points|
        squad_id = squad_for_user[point[:user_id]]

        key = [squad_id, point[:day], point[:challenge]]
        squad_points[key] += point[:score]
      end.map do |(squad_id, day, challenge), score|
        { score: score, squad_id: squad_id, day: day, challenge: challenge }
      end
    end
  end
end
