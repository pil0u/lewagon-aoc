# frozen_string_literal: true

class AddMissingIndexesOnState < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :states, :fetch_api_begin, algorithm: :concurrently
    add_index :states, :fetch_api_end, algorithm: :concurrently
  end
end
