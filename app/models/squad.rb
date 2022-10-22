# frozen_string_literal: true

class Squad < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..24 }

  before_validation :generate_pin_and_name, on: :create

  private

  def generate_pin_and_name
    pin = rand(100_000..999_999)
    pin = rand(100_000..999_999) while Squad.exists?(pin:)

    self.pin = pin
    self.name ||= "Squad #{Squad.any? ? Squad.last.id.next : 1}-#{SecureRandom.hex(4)}"
  end
end
