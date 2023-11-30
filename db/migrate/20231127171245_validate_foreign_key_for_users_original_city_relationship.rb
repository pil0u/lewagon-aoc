# frozen_string_literal: true

class ValidateForeignKeyForUsersOriginalCityRelationship < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :users, :cities
  end
end
