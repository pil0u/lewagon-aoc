# frozen_string_literal: true

class Squad < ApplicationRecord
  has_many :squad_points, class_name: "Cache::SquadPoint", dependent: :delete_all
  has_many :squad_scores, class_name: "Cache::SquadScore", dependent: :delete_all
  has_many :users, dependent: :nullify
  has_many :completions, through: :users

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..16 }

  before_validation :generate_pin_and_name, on: :create

  private

  def generate_pin_and_name
    pin = rand(100_000..999_999)
    pin = rand(100_000..999_999) while Squad.exists?(pin:)

    self.pin = pin
    self.name ||= "sq#{Squad.any? ? Squad.last.id.next : 1} - #{SecureRandom.hex(3)}"
  end
end
