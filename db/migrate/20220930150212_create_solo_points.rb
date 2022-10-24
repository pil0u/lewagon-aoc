# frozen_string_literal: true

class CreateSoloPoints < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :solo_points do |t|
      t.integer :day
      t.integer :challenge
      t.integer :score
      t.references :user, null: false, foreign_key: true
      t.timestamp :fetched_at, null: false

      t.timestamps
    end

    add_index :solo_points, :fetched_at, algorithm: :concurrently
    add_index :solo_points, %i[day challenge user_id fetched_at], unique: true, name: "unique_daychalluserfetch_on_solo_points"
  end
end
