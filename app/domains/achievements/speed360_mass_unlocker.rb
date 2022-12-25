# frozen_string_literal: true

module Achievements
  class Speed360MassUnlocker < MassUnlocker
    def call
      user_ids = Completion.where(duration: ..(6.hours)).distinct.pluck(:user_id)
      eligible_users = User.where(id: user_ids)

      unlock_for!(eligible_users)
    end
  end
end
