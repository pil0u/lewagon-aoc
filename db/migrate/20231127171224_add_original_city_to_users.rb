# frozen_string_literal: true

class AddOriginalCityToUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :users, :original_city, index: { algorithm: :concurrently }
    add_foreign_key :users, :cities, column: :original_city_id, validate: false
  end
end
