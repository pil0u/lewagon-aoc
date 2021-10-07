# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home]
  before_action :find_status, only: %i[dashboard]

  def home; end

  def about; end

  def dashboard
    @status_css = {
      "text-wagon-red-light": @status == "KO",
      "text-aoc-atmospheric": @status == "pending",
      "text-aoc-green": @status == "OK"
    }
  end

  def scoreboard; end

  private

  def find_status
    @status = current_user.status
  end
end
