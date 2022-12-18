# frozen_string_literal: true

module Achievements
  class Message10Unlocker < Unlocker
    def call
      return unless Message.where(user_id: user.id).count >= 10

      unlock!
    end
  end
end
