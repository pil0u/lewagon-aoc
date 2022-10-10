# frozen_string_literal: true

class RenameStatesColumns < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :states, :last_api_fetch_start, :fetch_api_begin
      rename_column :states, :last_api_fetch_end, :fetch_api_end
    end
  end
end
