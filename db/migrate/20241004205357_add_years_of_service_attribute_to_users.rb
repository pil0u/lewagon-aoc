# frozen_string_literal: true

class AddYearsOfServiceAttributeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :years_of_service, :integer, default: 0
  end
end
