# frozen_string_literal: true

module Header
  class NavTabComponent < ApplicationComponent
    def initialize(link:)
      @link = link
    end
  end
end
