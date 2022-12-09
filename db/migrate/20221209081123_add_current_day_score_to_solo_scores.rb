# frozen_string_literal: true

class AddCurrentDayScoreToSoloScores < ActiveRecord::Migration[7.0]
  def change
    add_column :solo_scores, :current_day_score, :integer
  end
end
