# frozen_string_literal: true

module Achievements
  class Edition2020MassUnlocker < MassUnlocker
    def call
      aoc_ids = [
        151_323, 1_095_582, 1_222_761, 1_258_899, 1_259_034, 1_259_062, 1_259_379, 1_266_861, 1_266_916, 1_267_074, 1_267_450, 1_276_674,
        1_276_836, 1_282_141, 1_283_809, 1_289_187, 1_289_409, 1_291_741, 1_292_231, 1_301_345, 1_304_972, 1_330_508, 1_331_786, 1_349_046
      ]
      eligible_users = User.where(aoc_id: aoc_ids)

      unlock_for!(eligible_users)
    end
  end
end
