# frozen_string_literal: true

module Cache
  class SoloPoint < ApplicationRecord
    belongs_to :user
  end
end
