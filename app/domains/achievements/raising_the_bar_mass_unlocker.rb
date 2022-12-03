module Achievements
  class RaisingTheBarMassUnlocker

    def call
      eligible_users = User.joins(:insanity_scores).where('score > 1000')
      unlock_for!(eligible_users)
    end
  end
end
