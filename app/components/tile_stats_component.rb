# frozen_string_literal: true

class TileStatsComponent < ApplicationComponent
  def initialize(title:, value:)
    @title = title
    @value = value
  end
end
