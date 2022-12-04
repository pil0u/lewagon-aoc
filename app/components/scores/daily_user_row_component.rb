# frozen_string_literal: true

class Scores::DailyUserRowComponent < ApplicationComponent
  include ApplicationHelper

  with_collection_parameter :user

  def initialize(user:)
    @user = user
  end
end
