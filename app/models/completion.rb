# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :user

  scope :actual, -> { where.not(completion_unix_time: nil) }
end
