# frozen_string_literal: true

require "help"

class City < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :completions, through: :users
  has_one :city_score # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view
  has_many :city_points # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view

  validates :name, uniqueness: { case_sensitive: false }

  MINIMUM_CONTRIBUTORS = 3

  def self.max_contributors
    [MINIMUM_CONTRIBUTORS, Help.median(User.synced.group(:city_id).count.except(nil).values) || 1].max
  end
end
