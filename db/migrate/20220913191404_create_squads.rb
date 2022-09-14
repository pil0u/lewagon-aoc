# frozen_string_literal: true

class CreateSquads < ActiveRecord::Migration[7.0]
  def change
    enable_extension("citext")

    create_table :squads do |t|
      t.citext :name
      t.integer :join_id

      t.timestamps
    end
  end
end
