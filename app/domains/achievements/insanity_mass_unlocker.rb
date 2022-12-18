# frozen_string_literal: true

module Achievements
  class InsanityMassUnlocker < MassUnlocker
    def call
      eligible_users = User.where(entered_hardcore: true)

      unlock_for!(eligible_users)
    end
  end
end
