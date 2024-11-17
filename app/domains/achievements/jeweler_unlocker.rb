# frozen_string_literal: true

module Achievements
  class JewelerUnlocker < Unlocker
    def call
      return unless user.snippets.exists?(language: "ruby")

      unlock!
    end
  end
end
