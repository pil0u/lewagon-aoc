# frozen_string_literal: true

class UserFormComponent < ApplicationComponent
  def initialize(user:)
    @user = user
    @awareness_options = {
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
    }
  end
end
