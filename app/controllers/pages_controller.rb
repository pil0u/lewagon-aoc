class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home]

  def home; end

  def dashboard
  end

  def scoreboard
  end

  def settings
  end
end
