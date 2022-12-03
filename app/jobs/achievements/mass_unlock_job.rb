# frozen_string_literal: true

class Achievements::MassUnlockJob < ApplicationJob
  queue_as :default

  def perform(nature)
    unlocker = "Achievements::#{nature.classify}MassUnlocker".safe_constantize
    raise "No Achievement MassUnlocker exist for nature #{nature.inspect}"
    unlocker.call
  end
end
