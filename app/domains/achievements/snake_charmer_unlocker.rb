# frozen_string_literal: true

module Achievements
  class SnakeCharmerUnlocker < Unlocker
    def call
      return unless user.snippets.exists?(language: "python")

      unlock!
    end
  end
end
