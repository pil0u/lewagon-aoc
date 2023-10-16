# frozen_string_literal: true

class ValidateAddNotNullConstraintAcceptedCoc < ActiveRecord::Migration[7.0]
  def up
    validate_check_constraint :users, name: "users_accepted_coc_null"
    change_column_null :users, :accepted_coc, false
    remove_check_constraint :users, name: "users_accepted_coc_null"
  end

  def down
    add_check_constraint :users, "accepted_coc IS NOT NULL", name: "users_accepted_coc_null", validate: false
    change_column_null :users, :accepted_coc, true
  end
end
