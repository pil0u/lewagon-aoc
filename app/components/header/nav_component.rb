# frozen_string_literal: true

module Header
  class NavComponent < ApplicationComponent
    include ScoresHelper

    def initialize(user:)
      @user = user
    end

    def render?
      helpers.user_signed_in?
    end
  end
end
