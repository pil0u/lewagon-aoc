# frozen_string_literal: true

class AddRememberCreateAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :remember_created_at, :datetime
  end
end
