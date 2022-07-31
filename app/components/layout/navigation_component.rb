# frozen_string_literal: true

module Layout
  class NavigationComponent < ApplicationComponent
    def initialize(user:)
      @user = user
    end

    def render?
      helpers.user_signed_in?
    end
  end
end
