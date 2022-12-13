# frozen_string_literal: true

module Cache
  class InsanityPoint < ApplicationRecord
    belongs_to :user
    belongs_to :completion
  end
end
