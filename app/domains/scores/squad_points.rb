# frozen_string_literal: true

module Scores
  class SquadPoints < CachedComputer
    def get
      cache(Cache::SquadPoint) { compute }
    end

    private

    RETURNED_ATTRIBUTES = %i[score squad_id day challenge].freeze

    def compute
      points = Scores::SoloPoints.get

      # index for o(1) fetch
      squad_for_user = User.where(id: points.pluck(:user_id)).pluck(:id, :squad_id).to_h

      # rubocop:disable Style/MultilineBlockChain
      points.each_with_object(Hash.new(0)) do |point, squad_points|
        squad_id = squad_for_user[point[:user_id]]
        next if squad_id.nil?

        key = [squad_id, point[:day], point[:challenge]]
        squad_points[key] += point[:score]
      end.compact.map do |(squad_id, day, challenge), score|
        { score:, squad_id:, day:, challenge: }
      end
      # rubocop:enable Style/MultilineBlockChain
    end
  end
end
