# frozen_string_literal: true

module Achievements
  class Stars5MassUnlocker < MassUnlocker
    def call
      user_ids = Completion.group(:user_id)
                           .count
                           .select { |_user_id, completions| completions >= 5 }
                           .keys
      eligible_users = User.where(id: user_ids)

      unlock_for!(eligible_users)
    end
  end
end
