class Achievement < ApplicationRecord
  belongs_to :user

  before_create do
    self.unlocked_at ||= Time.now
  end
end
