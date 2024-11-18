# frozen_string_literal: true

class AddGlobalScoreToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :aoc_global_score, :integer, default: 0
  end
end
