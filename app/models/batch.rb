# frozen_string_literal: true

class Batch < ApplicationRecord
  has_many :users, dependent: :nullify
  belongs_to :city

  validates :number, numericality: { in: 1...(2**31), message: "should be between 1 and 2^31" }, allow_nil: true
end
