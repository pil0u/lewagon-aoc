# frozen_string_literal: true

module Achievements
  class Edition2021MassUnlocker < MassUnlocker
    def call
      uids = File.readlines("db/static/achievement_edition2021_uids.txt").map(&:strip)
      eligible_users = User.where(uid: uids)

      unlock_for!(eligible_users)
    end
  end
end
