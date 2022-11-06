# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :sentry_set_user

  def sentry_set_user
    Sentry.set_user(
      id: current_user&.id,
      aoc_id: current_user&.aoc_id,
      github_username: current_user&.github_username
    )
  end
end
