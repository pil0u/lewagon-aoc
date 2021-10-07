# frozen_string_literal: true

class AddReferencesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :aoc_id, :integer
    add_index :users, :aoc_id
    add_reference :users, :batch, foreign_key: true
    add_reference :users, :city, foreign_key: true
  end
end
