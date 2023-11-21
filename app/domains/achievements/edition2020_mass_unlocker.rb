# frozen_string_literal: true

module Achievements
  class Edition2020MassUnlocker < MassUnlocker
    def call
      aoc_ids = File.readlines("db/static/achievement_edition2020_aoc_ids.txt").map(&:strip)
      eligible_users = User.where(aoc_id: aoc_ids)

      unlock_for!(eligible_users)
    end
  end
end
