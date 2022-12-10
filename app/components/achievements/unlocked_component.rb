# frozen_string_literal: true

class Achievements::UnlockedComponent < ApplicationComponent
  with_collection_parameter :nature

  def initialize(nature:)
    @nature = nature
  end
end
