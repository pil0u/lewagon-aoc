# frozen_string_literal: true

class CreateSquadPoints < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :squad_points do |t|
      t.integer :day
      t.integer :challenge
      t.integer :score
      t.references :squad, null: false, foreign_key: true
      t.timestamp :cache_key

      t.timestamps
    end

    add_index :squad_points, :cache_key, algorithm: :concurrently
    add_index :squad_points, %i[day challenge squad_id cache_key], unique: true, name: "unique_daychallsquadcache_on_solo_points"
  end
end
