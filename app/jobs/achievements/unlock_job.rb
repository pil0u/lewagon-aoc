# frozen_string_literal: true

module Achievements
  class UnlockJob < ApplicationJob
    queue_as :default

    def perform(nature, user_id)
      user = User.find(user_id)
      unlocker = "Achievements::#{nature.to_s.classify}Unlocker".safe_constantize
      raise "No Achievement Unlocker exist for nature #{nature.inspect}" unless unlocker

      unlocker.call(user)
    end
  end
end
