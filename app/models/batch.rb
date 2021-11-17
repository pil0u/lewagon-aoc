# frozen_string_literal: true

require "help"

class Batch < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :scores, through: :users

  def self.max_contributors
    Help.median(User.where(synced: true).group(:batch_id).count.except(nil).values) || 1
  end
end
