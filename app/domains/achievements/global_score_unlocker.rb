# frozen_string_literal: true

module Achievements
  class GlobalScoreUnlocker < Unlocker
    def call
      unlock!
    end
  end
end
