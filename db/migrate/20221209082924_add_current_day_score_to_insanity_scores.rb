class AddCurrentDayScoreToInsanityScores < ActiveRecord::Migration[7.0]
  def change
    add_column :insanity_scores, :current_day_score, :integer
  end
end
