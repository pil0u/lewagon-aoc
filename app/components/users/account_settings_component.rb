# frozen_string_literal: true

module Users
  class AccountSettingsComponent < ApplicationComponent
    AWARENESS_OPTIONS = {
      slack_aoc: "Channel #aoc on Slack",
      slack_general: "Channel #general on Slack",
      slack_campus: "Your campus channel on Slack",
      slack_batch: "Your batch channel on Slack",
      newsletter: "Email newsletter"
    }.freeze

    def initialize(user:)
      @user = user
    end
  end
end
