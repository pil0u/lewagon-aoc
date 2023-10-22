# frozen_string_literal: true

module Achievements
  class AchievementComponent < ApplicationComponent
    with_collection_parameter :achievement

    def initialize(achievement:, user_achievements:)
      @achievement = achievement
      @user_achievements = user_achievements
    end
  end
end
