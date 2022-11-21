# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true, length: { in: 4..256 }
end
