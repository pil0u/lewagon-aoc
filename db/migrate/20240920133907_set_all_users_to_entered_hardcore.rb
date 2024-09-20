# frozen_string_literal: true

class SetAllUsersToEnteredHardcore < ActiveRecord::Migration[7.1]
  def up
    User.update_all(entered_hardcore: true)
  end

  def down
    Rails.logger.warn("WARN: Nothing to do here, this migration was irreversible.")
  end
end
