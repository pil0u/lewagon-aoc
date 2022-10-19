class CreateNewCityScores < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    drop_view :city_scores, materialized: true, revert_to_version: 2

    create_table :city_scores do |t|
      t.integer :score
      t.references :city, null: false, foreign_key: true
      t.timestamp :cache_fingerprint

      t.timestamps
    end

    add_index :city_scores, :cache_fingerprint, algorithm: :concurrently
    add_index :city_scores, [:city_id, :cache_fingerprint], unique: true,
      algorithm: :concurrently
  end
end
