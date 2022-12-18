# frozen_string_literal: true

module Achievements
  class SanityMassUnlocker < MassUnlocker
    def call
      eligible_users = User.where(entered_hardcore: false)

      unlock_for!(eligible_users)
    end
  end
end
