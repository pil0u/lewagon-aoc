# frozen_string_literal: true

module Achievements
  class JediMasterMassUnlocker < MassUnlocker
    def call
      eligible_users = User.where("aoc_global_score > 0")

      unlock_for!(eligible_users)
    end
  end
end
