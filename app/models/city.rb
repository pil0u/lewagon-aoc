# frozen_string_literal: true

class City < ApplicationRecord
  has_many :city_points, class_name: "Cache::CityPoint", dependent: :delete_all
  has_many :city_scores, class_name: "Cache::CityScore", dependent: :delete_all

  has_many :users, dependent: :nullify
  has_many :original_users, class_name: "User", dependent: :nullify
  has_many :completions, through: :users

  before_create :set_default_vanity_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.find_by_slug(slug)
    find_by!("REPLACE(LOWER(name), ' ', '-') = ?", slug)
  end

  def self.slugify(name)
    name.tr(" ", "-").downcase
  end

  def slug
    self.class.slugify(name)
  end

  private

  def set_default_vanity_name
    self.vanity_name ||= name
  end
end
