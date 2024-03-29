# frozen_string_literal: true

module Achievements
  class MassUnlockJob < ApplicationJob
    queue_as :default

    def perform(nature)
      unlocker = "Achievements::#{nature.to_s.classify}MassUnlocker".safe_constantize
      raise "No Achievement MassUnlocker exist for nature #{nature.inspect}" unless unlocker

      unlocker.call
    end
  end
end
