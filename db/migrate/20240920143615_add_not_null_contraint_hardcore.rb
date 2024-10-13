# frozen_string_literal: true

class AddNotNullContraintHardcore < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :users, "entered_hardcore IS NOT NULL", name: "users_entered_hardcore_null", validate: false
  end
end
