# frozen_string_literal: true

class Squad < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, uniqueness: { case_sensitive: false }

  before_create :generate_secret_id

  private

  def generate_secret_id
    self.secret_id = rand(100_000..999_999) while Squad.exists?(secret_id:)
  end
end
