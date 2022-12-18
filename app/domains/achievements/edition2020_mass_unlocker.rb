# frozen_string_literal: true

module Achievements
  class Edition2020MassUnlocker < MassUnlocker
    def call
      aoc_ids = [
        151323, 1095582, 1222761, 1258899, 1259034, 1259062, 1259379, 1266861, 1266916, 1267074, 1267450, 1276674,
        1276836, 1282141, 1283809, 1289187, 1289409, 1291741, 1292231, 1301345, 1304972, 1330508, 1331786, 1349046
      ]
      eligible_users = User.where(aoc_id: aoc_ids)

      unlock_for!(eligible_users)
    end
  end
end
