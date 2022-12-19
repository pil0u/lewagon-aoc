# frozen_string_literal: true

module Achievements
  class Message5Unlocker < Unlocker
    def call
      return unless user.messages.count >= 5

      unlock!
    end
  end
end
