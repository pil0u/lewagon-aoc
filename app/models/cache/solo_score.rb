# frozen_string_literal: true

module Cache
  class SoloScore < ApplicationRecord
    belongs_to :user
  end
end
