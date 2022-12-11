# frozen_string_literal: true

module Cache
  class CityPoint < ApplicationRecord
    belongs_to :city
  end
end
