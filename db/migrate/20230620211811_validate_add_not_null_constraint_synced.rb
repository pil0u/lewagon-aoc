# frozen_string_literal: true

class ValidateAddNotNullConstraintSynced < ActiveRecord::Migration[7.0]
  def up
    validate_check_constraint :users, name: "users_synced_null"
    change_column_null :users, :synced, false
    remove_check_constraint :users, name: "users_synced_null"
  end

  def down
    add_check_constraint :users, "synced IS NOT NULL", name: "users_synced_null", validate: false
    change_column_null :users, :synced, true
  end
end
