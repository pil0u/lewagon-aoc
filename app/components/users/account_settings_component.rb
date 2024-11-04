# frozen_string_literal: true

module Users
  class AccountSettingsComponent < ApplicationComponent
    AWARENESS_OPTIONS = {
      newsletter: "Email newsletter",
      slack_aoc: "Channel #aoc on Slack",
      slack_general: "Channel #general on Slack",
      slack_payforward: "Channel #pay-forward on Slack",
      slack_campus: "Your campus channel on Slack",
      slack_batch: "Your batch channel on Slack",
      other: "Other"
    }.freeze

    def initialize(user:)
      @user = user
      @form_awareness_options = AWARENESS_OPTIONS.invert.to_a
    end
  end
end
