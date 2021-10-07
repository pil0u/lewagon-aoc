# frozen_string_literal: true

class RenameAttributesStates < ActiveRecord::Migration[6.1]
  def change
    rename_column :states, :last_api_check_start, :last_api_fetch_start
    rename_column :states, :last_api_check_end, :last_api_fetch_end
  end
end
