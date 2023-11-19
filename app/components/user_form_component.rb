# frozen_string_literal: true

class UserFormComponent < ApplicationComponent
  AWARENESS_OPTIONS = {
    slack_aoc: "Slack channel #aoc",
    slack_general: "Slack channel #general",
    slack_campus: "Slack channel of your campus",
    slack_batch: "Slack channel of your batch",
    newsletter: "Email newsletter",
    linkedin: "Linkedin",
    facebook: "Facebook",
    instagram: "Instagram",
    brussels_event: "Launch party in Brussels",
    london_event: "Testing workshop in London"
  }.freeze

  def initialize(user:)
    @user = user
  end
end
