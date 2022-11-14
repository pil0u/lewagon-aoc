# frozen_string_literal: true

module Cache
  class InsanityScore < ApplicationRecord
    belongs_to :user
  end
end
