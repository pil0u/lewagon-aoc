# frozen_string_literal: true

class Achievement < ApplicationRecord
  belongs_to :user

  before_create do
    self.unlocked_at ||= Time.now.utc
  end

  def self.full_list
    I18n.t("achievements")
  end

  def self.keys
    full_list.keys
  end

  def self.total
    full_list.count - 1
    # :sanity and :insanity are mutually exclusive
  end
end
