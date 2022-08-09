# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  def initialize(flash:)
    @flash = flash
  end
end
