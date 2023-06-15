# frozen_string_literal: true

class City < ApplicationRecord
  self.ignored_columns += ["size"]

  has_many :city_points, class_name: "Cache::CityPoint", dependent: :delete_all
  has_many :city_scores, class_name: "Cache::CityScore", dependent: :delete_all

  has_many :batches, dependent: :nullify
  has_many :users, through: :batches
  has_many :completions, through: :users

  validates :name, uniqueness: { case_sensitive: false }

  def self.find_by_slug(slug)
    find_by!("REPLACE(LOWER(name), ' ', '-') = ?", slug)
  end

  def self.slugify(name)
    name.tr(" ", "-").downcase
  end

  def slug
    self.class.slugify(name)
  end

  def top_contributors
    [10, (batches.sum(:size) * 0.03).ceil].max
  end
end
