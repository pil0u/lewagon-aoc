# frozen_string_literal: true

class CreateSoloScores < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :solo_scores do |t|
      t.integer :score
      t.references :user, null: false, foreign_key: true
      t.timestamp :fetched_at

      t.timestamps
    end

    add_index :solo_scores, :fetched_at, algorithm: :concurrently
    add_index :solo_scores, %i[user_id fetched_at], unique: true
  end
end
