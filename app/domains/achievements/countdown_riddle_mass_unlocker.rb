# frozen_string_literal: true

module Achievements
  class CountdownRiddleMassUnlocker < MassUnlocker
    def call
      eligible_users = User.where(uid: %w[171 5134 7665 11200 13740 14764])

      unlock_for!(eligible_users)
    end
  end
end
