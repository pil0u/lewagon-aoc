# frozen_string_literal: true

class CreatePuzzles < ActiveRecord::Migration[7.1]
  def change
    create_table :puzzles do |t|
      t.date :date, null: false
      t.string :slack_url
      t.string :title

      t.timestamps
    end

    add_index :puzzles, :date, unique: true
  end
end
