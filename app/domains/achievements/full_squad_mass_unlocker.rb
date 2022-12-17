# frozen_string_literal: true

module Achievements
  class FullSquadMassUnlocker < MassUnlocker
    def call
      full_squads = User.group(:squad_id)
                        .where.not(squad_id: nil)
                        .count
                        .select { |_id, members| members == 4 }
                        .keys
      eligible_users = User.where(squad_id: full_squads)

      unlock_for!(eligible_users)
    end
  end
end
