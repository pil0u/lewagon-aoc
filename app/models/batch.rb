# frozen_string_literal: true

class Batch < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :scores, through: :users
end
