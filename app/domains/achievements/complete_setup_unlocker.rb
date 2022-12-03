module Achievements
  class CompleteSetupUnlocker < Unlocker

    def call
      return unless user.synced && user.accepted_coc

      unlock!
    end
  end
end
