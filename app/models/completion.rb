# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :user

  scope :actual, -> { where.not(day: 0) }
end
