# frozen_string_literal: true

class CreateInsanityScores < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :insanity_scores do |t|
      t.integer :score
      t.references :user, null: false, foreign_key: true
      t.string :cache_fingerprint, null: false

      t.timestamps
    end

    add_index :insanity_scores, :cache_fingerprint, algorithm: :concurrently
    add_index :insanity_scores, %i[user_id cache_fingerprint], unique: true
  end
end
