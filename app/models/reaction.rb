# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :snippet

  validates :content, presence: true, inclusion: %w[clapping learning mind_blown]

  validate :cannot_vote_for_self
  validate :max_one_reaction_per_snippet_per_user

  def cannot_vote_for_self
    return unless snippet.user_id == user_id

    errors.add(:user, "cannot vote for themself")
  end

  def max_one_reaction_per_snippet_per_user
    return unless snippet.reactions.where(user_id:).length > 1

    errors.add(:user, "cannot react multiple times to the same code snippet")
  end
end
