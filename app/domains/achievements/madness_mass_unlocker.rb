# frozen_string_literal: true

module Achievements
  class MadnessMassUnlocker < MassUnlocker
    def call
      scores = Scores::InsanityScores.get.select { |score| score[:score] > 0 }
      eligible_users = User.where(id: scores.pluck(:user_id))

      unlock_for!(eligible_users)
    end
  end
end
