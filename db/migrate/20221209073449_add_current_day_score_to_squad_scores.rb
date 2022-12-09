class AddCurrentDayScoreToSquadScores < ActiveRecord::Migration[7.0]
  def change
    add_column :squad_scores, :current_day_score, :integer
  end
end
