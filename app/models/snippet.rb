class Snippet < ApplicationRecord
  LANGUAGES = %w(java javascript python ruby)

  belongs_to :user

  validates :code, presence: true
  validates :language, inclusion: { in: LANGUAGES }
  validates :user_id, uniqueness: { scope: [:day, :challenge, :language], message: "can submit only 1 solution per language" }
end
