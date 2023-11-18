# frozen_string_literal: true

class Snippet < ApplicationRecord
  belongs_to :user

  validates :code, presence: true
  validates :language, inclusion: { in: LANGUAGES.keys.map(&:to_s) }
  validates :user_id, uniqueness: { scope: %i[day challenge language], message: "can submit only 1 solution per language" }
end
