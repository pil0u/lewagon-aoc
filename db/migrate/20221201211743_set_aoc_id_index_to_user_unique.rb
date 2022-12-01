# frozen_string_literal: true

class SetAocIdIndexToUserUnique < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :users, :aoc_id, algorithm: :concurrently
    add_index :users, :aoc_id, unique: true, algorithm: :concurrently
  end
end
