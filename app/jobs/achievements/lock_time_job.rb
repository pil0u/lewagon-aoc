# frozen_string_literal: true

module Achievements
  class LockTimeJob < ApplicationJob
    queue_as :default

    def perform
      Achievements::MassUnlockJob.perform_later(:locked_loaded)
    end
  end
end
