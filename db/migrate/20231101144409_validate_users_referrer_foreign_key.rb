# frozen_string_literal: true

class ValidateUsersReferrerForeignKey < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :users, :users, column: :referrer_id
  end
end
