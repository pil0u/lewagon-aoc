# frozen_string_literal: true

module Stats
  class TileComponent < ApplicationComponent
    def initialize(title:, value:)
      @title = title
      @value = value
    end
  end
end