# frozen_string_literal: true

class ValidateAddNotNullConstraintEnteredHardcore < ActiveRecord::Migration[7.0]
  def up
    validate_check_constraint :users, name: "users_entered_hardcore_null"
    change_column_null :users, :entered_hardcore, false
    remove_check_constraint :users, name: "users_entered_hardcore_null"
  end

  def down
    add_check_constraint :users, "entered_hardcore IS NOT NULL", name: "users_entered_hardcore_null", validate: false
    change_column_null :users, :entered_hardcore, true
  end
end
