# frozen_string_literal: true

class Squad < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, uniqueness: { case_sensitive: false }

  before_create :generate_join_id

  private

  def generate_join_id
    self.join_id = rand(100_000..999_999) while Squad.exists?(join_id:)
  end
end
