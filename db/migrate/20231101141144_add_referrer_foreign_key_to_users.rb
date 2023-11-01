# frozen_string_literal: true

class AddReferrerForeignKeyToUsers < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :users, :users, column: :referrer_id, validate: false
  end
end
