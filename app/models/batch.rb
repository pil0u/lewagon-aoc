# frozen_string_literal: true

require "help"

class Batch < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :completions, through: :users
  # These are SQL views
  has_one :score, class_name: 'BatchScore' # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :points, class_name: 'BatchPoint' # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :day_scores, class_name: 'BatchDayScores' # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :contributions, class_name: 'BatchContribution' # rubocop:disable Rails/HasManyOrHasOneDependent
  ###

  MINIMUM_CONTRIBUTORS = 3

  def self.max_contributors
    [MINIMUM_CONTRIBUTORS, Help.median(User.synced.group(:batch_id).count.except(nil).values) || 1].max
  end
end
