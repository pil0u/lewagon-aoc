# frozen_string_literal: true

module Achievements
  class SetupCompleteMassUnlocker < MassUnlocker
    def call
      eligible_users = User.where(synced: true)

      unlock_for!(eligible_users)
    end
  end
end
