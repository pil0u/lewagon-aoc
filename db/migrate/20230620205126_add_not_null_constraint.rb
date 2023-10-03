# frozen_string_literal: true

class AddNotNullConstraint < ActiveRecord::Migration[7.0]
  def change
    add_check_constraint :users, "accepted_coc IS NOT NULL", name: "users_accepted_coc_null", validate: false
    add_check_constraint :users, "synced IS NOT NULL", name: "users_synced_null", validate: false
    add_check_constraint :users, "entered_hardcore IS NOT NULL", name: "users_entered_hardcore_null", validate: false
  end
end
