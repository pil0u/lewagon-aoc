# frozen_string_literal: true

module Achievements
  class UnlockedComponent < ApplicationComponent
    def initialize(nature:, state:, title:)
      @nature, @title, @state_css = {
        locked: ["surprise", random_locked_message, "achievement-locked"],
        unlocked: [nature, title, "achievement-unlocked"],
        unlocked_plus: [nature, title, "achievement-unlocked-plus"]
      }[state]
    end

    private

    def random_locked_message
      [
        "Soon™",
        "Nothing to see here... yet!",
        "Click to reveal! Nah, just kidding.",
        "Legend says this achievement exists...",
        "Keep trying! Or don't. I'm just a tooltip.",
        "Do you really wanna know what's behind this?",
        "This achievement is shy and doesn't want to come out"
      ].sample
    end
  end
end
