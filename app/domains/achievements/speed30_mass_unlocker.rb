# frozen_string_literal: true

module Achievements
  class Speed30MassUnlocker < MassUnlocker
    def call
      user_ids = Completion.where(duration: ..(30.minutes))
                           .group(:user_id)
                           .pluck(:user_id)
      eligible_users = User.where(id: user_ids)

      unlock_for!(eligible_users)
    end
  end
end
