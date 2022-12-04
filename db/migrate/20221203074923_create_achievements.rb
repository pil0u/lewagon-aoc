# frozen_string_literal: true

class CreateAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :achievements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :nature
      t.timestamp :unlocked_at

      t.timestamps
    end
    add_index :achievements, :nature
    add_index :achievements, :unlocked_at
  end
end
