# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { in: 4..512 }

  PLACEHOLDERS = [
    "You just lost The Game",
    "You will be baked, and then there will be cake",
    "Did I ever tell you the definition of insanity?",
    "With great power comes great responsibility",
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "Break me"
  ]
end
