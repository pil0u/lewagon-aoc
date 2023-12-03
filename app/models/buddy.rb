# frozen_string_literal: true

class Buddy < ApplicationRecord
  scope :of_today, -> { where(day: Aoc.latest_day) }
  scope :of_user,  ->(user_id) { where("id_1 = ? OR id_2 = ?", user_id, user_id) }

  def self.of_the_day(user)
    buddy_pair = of_today.of_user(user.id).first
    daily_buddy_id = user.id == buddy_pair.id_1 ? buddy_pair.id_2 : buddy_pair.id_1 if buddy_pair

    User.find_by(id: daily_buddy_id)
  end
end
