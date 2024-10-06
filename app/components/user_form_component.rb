# frozen_string_literal: true

class UserFormComponent < ApplicationComponent
  AWARENESS_OPTIONS = {
    slack_aoc: "Channel #aoc on Slack ",
    slack_general: "Channel #general on Slack ",
    slack_campus: "Your campus channel on Slack ",
    slack_batch: "Your batch channel on Slack",
    newsletter: "Email newsletter",
    linkedin: "LinkedIn",
    facebook: "Facebook",
    instagram: "Instagram",
    event_brussels: "At Brussels' launch party",
    event_london: "At London's workshop in testing"
  }.freeze

  def initialize(user:)
    @user = user
  end
end
