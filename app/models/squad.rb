# frozen_string_literal: true

class Squad < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_validation :generate_secret_id, on: :create

  private

  def generate_secret_id
    secret_id = rand(100_000..999_999)
    while Squad.exists?(secret_id: secret_id)
      secret_id = rand(100_000..999_999)
    end

    self.secret_id = secret_id
    self.name = "Squad #{Squad.any? ? Squad.last.id.next : 1}-#{SecureRandom.hex(4)}"
  end
end
