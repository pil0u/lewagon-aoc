# frozen_string_literal: true

class AddIndexesToScores < ActiveRecord::Migration[6.1]
  def change
    add_index :scores, %i[user_id day challenge], unique: true
  end
end
