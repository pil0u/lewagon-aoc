# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :render_maintenance, if: :maintenance_mode?
  before_action :authenticate_user!
  before_action :sentry_set_user
  before_action :render_countdown, if: :render_countdown?

  private

  def maintenance_mode?
    ENV["MAINTENANCE_MODE"] == "true"
  end

  def render_maintenance
    render "pages/maintenance", layout: false
  end

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
    !devise_controller? && !beta_tester? && before_launch? && true_production?
  end

  def beta_tester?
    current_user&.beta_tester?
  end

  def before_launch?
    Time.now.utc < Aoc.lewagon_launch_time
  end

  def true_production?
    Rails.env.production? && !ENV["THIS_IS_STAGING"]
  end
end
