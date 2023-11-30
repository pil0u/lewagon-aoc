# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :snippet

  validates :reaction_type, presence: true, inclusion: %w[clapping learning mind_blown]

  validate :cannot_vote_for_self
  validate :max_one_reaction_per_snippet_per_user

  def cannot_vote_for_self
    return unless snippet.user_id == user_id

    errors.add(:base, "Did you try to give yourself a high-five?")
  end

  def max_one_reaction_per_snippet_per_user
    return unless Reaction.where(user_id:, snippet_id:).count > 1

    errors.add(:user, "cannot react multiple times to the same code snippet")
  end
end
