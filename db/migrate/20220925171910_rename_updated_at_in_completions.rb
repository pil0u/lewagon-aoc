# frozen_string_literal: true

class RenameUpdatedAtInCompletions < ActiveRecord::Migration[7.0]
  def change
    safety_assured { rename_column :completions, :updated_at, :created_at }
  end
end
