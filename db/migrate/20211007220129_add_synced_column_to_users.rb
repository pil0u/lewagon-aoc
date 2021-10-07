# frozen_string_literal: true

class AddSyncedColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :synced, :boolean, default: false
  end
end
