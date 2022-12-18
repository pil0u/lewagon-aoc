# frozen_string_literal: true

module Achievements
  class Message1Unlocker < Unlocker
    def call
      return unless Message.where(user_id: user.id).count >= 1

      unlock!
    end
  end
end
