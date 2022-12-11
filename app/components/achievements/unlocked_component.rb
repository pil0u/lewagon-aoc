# frozen_string_literal: true

module Achievements
  class UnlockedComponent < ApplicationComponent
    with_collection_parameter :nature

    def initialize(nature:)
      @nature = nature
    end
  end
end
