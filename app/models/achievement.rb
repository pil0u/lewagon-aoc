# frozen_string_literal: true

class Achievement < ApplicationRecord
  belongs_to :user

  # Define a scope for each achievement type
  # edition2020 edition2021 countdown_riddle setup_complete city_join full_squad sanity insanity stars1 stars5 stars11 stars23 speed10 speed30 speed90 speed180].each do |nature|
  %i[fan jedi_master].each do |nature|
    scope nature, -> { where(nature: nature.to_s) }
  end

  before_create do
    self.unlocked_at ||= Time.now.utc
  end
end
