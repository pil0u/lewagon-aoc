# frozen_string_literal: true

module Achievements
  class Speed720MassUnlocker < MassUnlocker
    def call
      user_ids = Completion.where(duration: ..12.hours)
                           .group(:user_id)
                           .pluck(:user_id)
      eligible_users = User.where(id: user_ids)

      unlock_for!(eligible_users)
    end
  end
end
