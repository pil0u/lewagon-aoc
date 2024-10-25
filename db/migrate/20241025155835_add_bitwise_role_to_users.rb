# frozen_string_literal: true

class AddBitwiseRoleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :roles, :integer, null: false, default: 0
  end
end
