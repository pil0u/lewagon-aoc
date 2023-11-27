# frozen_string_literal: true

module Footer
  class NavComponent < ApplicationComponent
    def initialize(user:)
      @user = user
    end
  end
end
