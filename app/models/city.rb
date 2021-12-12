# frozen_string_literal: true

require "help"

class City < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :completions, through: :users
  # These are SQL views
  has_one :score, class_name: 'CityScore' # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :points, class_name: 'CityPoint' # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :day_scores, class_name: 'CityDayScores' # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :contributions, class_name: 'CityContribution' # rubocop:disable Rails/HasManyOrHasOneDependent
  ###

  validates :name, uniqueness: { case_sensitive: false }

  MINIMUM_CONTRIBUTORS = 3

  def self.max_contributors
    [MINIMUM_CONTRIBUTORS, Help.median(User.synced.group(:city_id).count.except(nil).values) || 1].max
  end

  def self.find_by_slug(slug)
    find_by("REPLACE(LOWER(name), ' ', '_') = ?", slug)
  end

  def self.slugify(name)
    name.tr(" ", "_").downcase
  end

  def slug
    self.class.slugify(name)
  end
end
