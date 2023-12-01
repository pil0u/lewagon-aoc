# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :snippet

  validates :user, uniqueness: { scope: :snippet_id, message: "cannot react multiple times to the same code snippet" }
  validates :reaction_type, presence: true, inclusion: %w[clapping learning mind_blown]

  validate :cannot_vote_for_self

  def cannot_vote_for_self
    return unless snippet.user_id == user_id

    errors.add(:base, "Did you try to give yourself a high-five?")
  end
end
