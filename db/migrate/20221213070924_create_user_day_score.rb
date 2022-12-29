# frozen_string_literal: true

class CreateUserDayScore < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :user_day_scores do |t|
      t.integer :score
      t.integer :day
      t.references :user, null: false, index: { algorithm: :concurrently }
      t.references :part_1_completion, index: { algorithm: :concurrently }
      t.references :part_2_completion, index: { algorithm: :concurrently }
      t.string :cache_fingerprint

      t.timestamps
    end

    add_index :user_day_scores, :cache_fingerprint, algorithm: :concurrently
    add_index :user_day_scores, %i[day user_id cache_fingerprint], unique: true, name: "unique_dayusercache_on_user_day_scores"
  end
end
