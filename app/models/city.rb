# frozen_string_literal: true

class City < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, uniqueness: true
end
