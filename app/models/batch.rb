# frozen_string_literal: true

require "help"

class Batch < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :scores, through: :users

  MINIMUM_CONTRIBUTORS = 3

  def self.max_contributors
    [Help.median(User.synced.group(:batch_id).count.except(nil).values) || 1, MINIMUM_CONTRIBUTORS].max
  end
end
