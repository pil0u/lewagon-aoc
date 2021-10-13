# frozen_string_literal: true

class City < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :scores, through: :users

  validates :name, uniqueness: { case_sensitive: false }
end
