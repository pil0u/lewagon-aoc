# frozen_string_literal: true

module Layout
  class NavigationLinkComponent < ApplicationComponent
    def initialize(link:)
      @link = link
    end
  end
end
