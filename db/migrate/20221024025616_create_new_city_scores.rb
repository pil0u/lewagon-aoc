# frozen_string_literal: true

class CreateNewCityScores < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :city_scores do |t|
      t.integer :score
      t.references :city, null: false, foreign_key: true
      t.string :cache_fingerprint

      t.timestamps
    end

    add_index :city_scores, :cache_fingerprint, algorithm: :concurrently
    add_index :city_scores, %i[city_id cache_fingerprint], unique: true, algorithm: :concurrently
  end
end
