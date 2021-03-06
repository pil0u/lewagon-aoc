# frozen_string_literal: true

class CreateScores < ActiveRecord::Migration[6.1]
  def change
    create_table :scores do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day, limit: 1
      t.integer :challenge, limit: 1
      t.integer :completion_unix_time, limit: 8
      t.integer :score
      t.datetime :updated_at, precision: 6, null: false
    end

    add_index :scores, %i[user_id day challenge], unique: true
  end
end
