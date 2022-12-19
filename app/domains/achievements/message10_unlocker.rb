# frozen_string_literal: true

module Achievements
  class Message10Unlocker < Unlocker
    def call
      return unless user.messages.count >= 10

      unlock!
    end
  end
end
