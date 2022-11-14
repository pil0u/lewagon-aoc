# frozen_string_literal: true

class CreateInsanityPoints < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :insanity_points do |t|
      t.integer :day
      t.integer :challenge
      t.integer :score
      t.references :user, null: false, foreign_key: true
      t.string :cache_fingerprint, null: false

      t.timestamps
    end

    add_index :insanity_points, :cache_fingerprint, algorithm: :concurrently
    add_index :insanity_points, %i[day challenge user_id cache_fingerprint], unique: true,
                                                                             name: "unique_daychalluserfetch_on_insanity_points"
  end
end
