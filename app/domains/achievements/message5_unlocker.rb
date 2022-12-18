# frozen_string_literal: true

module Achievements
  class Message5Unlocker < Unlocker
    def call
      return unless Message.where(user_id: user.id).count >= 5

      unlock!
    end
  end
end
