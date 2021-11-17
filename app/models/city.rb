# frozen_string_literal: true

require "help"

class City < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :scores, through: :users

  validates :name, uniqueness: { case_sensitive: false }

  def self.max_contributors
    Help.median(User.synced.group(:city_id).count.except(nil).values) || 1
  end
end
