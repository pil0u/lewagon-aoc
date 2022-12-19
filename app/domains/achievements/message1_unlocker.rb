# frozen_string_literal: true

module Achievements
  class Message1Unlocker < Unlocker
    def call
      return unless user.messages.count >= 1

      unlock!
    end
  end
end
