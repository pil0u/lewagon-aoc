# frozen_string_literal: true

class State < ApplicationRecord
  scope :with_changes, -> { where.not(completions_fetched: 0) }
end
