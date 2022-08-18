# frozen_string_literal: true

require "help"

class Batch < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :completions, through: :users
  has_one :batch_score # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view
  has_many :batch_points # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view

  validates :number, numericality: { in: 1...(2**31), message: "should be between 1 and 2^31" }

  MINIMUM_CONTRIBUTORS = 3

  def self.max_contributors
    [MINIMUM_CONTRIBUTORS, Help.median(User.synced.group(:batch_id).count.except(nil).values) || 1].max
  end
end
