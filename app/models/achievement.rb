# frozen_string_literal: true

class Achievement < ApplicationRecord
  belongs_to :user

  before_create do
    self.unlocked_at ||= Time.zone.now
  end
end
