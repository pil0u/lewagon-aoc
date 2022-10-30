# frozen_string_literal: true

module Cache
  class SquadScore < ApplicationRecord
    belongs_to :squad
  end
end
