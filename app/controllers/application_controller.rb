# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :sentry_set_user
  before_action :render_countdown, if: :render_countdown?

  private

  def sentry_set_user
    Sentry.set_user(
      id: current_user&.id,
      aoc_id: current_user&.aoc_id,
      github_username: current_user&.github_username
    )
  end

  def render_countdown
    render "pages/countdown", layout: false
  end

  def render_countdown?
    !devise_controller? && !admin? && before_launch? && true_production?
  end

  def admin?
    current_user&.admin?
  end

  def before_launch?
    Time.now.utc < Aoc.lewagon_launch_time
  end

  def true_production?
    Rails.env.production? && !ENV["THIS_IS_STAGING"]
  end
end
