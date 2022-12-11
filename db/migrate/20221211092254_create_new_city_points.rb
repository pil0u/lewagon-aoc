# frozen_string_literal: true

class CreateNewCityPoints < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    drop_view :city_points, materialized: true, revert_to_version: 2

    create_table :city_points do |t|
      t.integer :day
      t.integer :challenge
      t.decimal :score
      t.integer :total_score
      t.integer :contributor_count
      t.references :city, null: false, foreign_key: true
      t.string :cache_fingerprint

      t.timestamps
    end

    add_index :city_points, :cache_fingerprint, algorithm: :concurrently
    add_index :city_points, %i[day challenge city_id cache_fingerprint], unique: true, algorithm: :concurrently,
                                                                         name: "unique_daychallcityfing_on_city_points"
  end
end
