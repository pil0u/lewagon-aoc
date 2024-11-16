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
        "Click to reveal! Nah, just kidding.",
        "Soon™",
        "Do you really wanna know what's behind this?",
        "Nothing to see here... yet!",
        "This achievement is shy and doesn't want to come out",
        "Keep trying! Or don't. I'm just a tooltip.",
        "Legend says this achievement exists...",
        "The achievement is in another castle!"
      ].sample
    end
  end
end
