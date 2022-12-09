class AddCurrentDayScoreToCityScores < ActiveRecord::Migration[7.0]
  def change
    add_column :city_scores, :current_day_score, :integer
    add_column :city_scores, :current_day_part_1_contributors, :integer
    add_column :city_scores, :current_day_part_2_contributors, :integer
  end
end
