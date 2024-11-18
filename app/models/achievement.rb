# frozen_string_literal: true

class Achievement < ApplicationRecord
  belongs_to :user

  %i[fan jedi_master madness].each do |nature|
    scope nature, -> { where(nature: nature.to_s) }
  end

  before_create do
    self.unlocked_at ||= Time.now.utc
  end
end
