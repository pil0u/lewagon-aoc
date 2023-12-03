# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  def initialize(flash:)
    @flash = flash
    @flash_type_css_class = {
      "alert" => "bg-dark text-wagon-red border border-wagon-red",
      "notice" => "bg-aoc-gray text-dark"
    }
  end
end
