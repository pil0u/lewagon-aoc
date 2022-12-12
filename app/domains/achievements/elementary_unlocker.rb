# frozen_string_literal: true

module Achievements
  class ElementaryUnlocker < Unlocker
    def call
      return unless user.uid.in? ["171", "5134", "7665", "11200", "13740", "14764"]

      unlock!
    end
  end
end
