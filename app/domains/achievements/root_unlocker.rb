# frozen_string_literal: true

module Achievements
  class RootUnlocker < Unlocker
    def call
      return unless user.city_id

      unlock!
    end
  end
end
