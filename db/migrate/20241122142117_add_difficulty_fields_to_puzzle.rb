# frozen_string_literal: true

class AddDifficultyFieldsToPuzzle < ActiveRecord::Migration[7.2]
  def change
    add_column :puzzles, :difficulty_level, :integer
    add_column :puzzles, :is_difficulty_final, :boolean, default: false, null: false
  end
end
