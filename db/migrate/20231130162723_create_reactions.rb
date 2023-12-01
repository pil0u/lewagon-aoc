# frozen_string_literal: true

class CreateReactions < ActiveRecord::Migration[7.1]
  def change
    create_table :reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :snippet, null: false, foreign_key: true
      t.string :reaction_type, null: false

      t.timestamps
    end

    add_index :reactions, %i[user_id snippet_id], unique: true
  end
end
