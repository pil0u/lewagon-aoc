# frozen_string_literal: true

module Cache
  class SquadPoint < ApplicationRecord
    belongs_to :squad
  end
end
