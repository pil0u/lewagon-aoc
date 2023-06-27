# frozen_string_literal: true

class AddReferencesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :aoc_id, :integer
    add_column :users, :synced, :boolean, default: false # rubocop:disable Rails/ThreeStateBooleanColumn
    add_reference :users, :batch, foreign_key: true
    add_reference :users, :city, foreign_key: true

    add_index :users, :aoc_id
  end
end
