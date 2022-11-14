# frozen_string_literal: true

module Cache
  class CityScore < ApplicationRecord
    belongs_to :city
  end
end
