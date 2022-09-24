# frozen_string_literal: true

class AddIndexToSquads < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :squads, :name, unique: true, algorithm: :concurrently
  end
end
