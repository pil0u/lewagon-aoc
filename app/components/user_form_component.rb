# frozen_string_literal: true

class UserFormComponent < ApplicationComponent
  def initialize(user:)
    @user = user
    @awareness_options = {
      aoc: "Slack channel #aoc",
      general: "Slack channel #general",
      campus: "Slack channel of your campus",
      batch: "Slack channel of your batch",
      newsletter: "Email newsletter",
      linkedin: "Linkedin",
      facebook: "Facebook",
      instagram: "Instagram"
    }

    @awareness_options[:city_event] = "Launch party in Brussels" if @user.city.name == "Brussels"
    @awareness_options[:city_event] = "Testing workshop in London" if @user.city.name == "London"
  end
end
