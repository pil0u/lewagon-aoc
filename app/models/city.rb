# frozen_string_literal: true

require "help"

class City < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :completions, through: :users
  has_one :city_score # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view
  has_many :city_points # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view

  validates :name, uniqueness: { case_sensitive: false }

  def self.max_contributors
    Help.median(User.synced.group(:city_id).count.except(nil).values) || 1
  end
end
