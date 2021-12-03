# frozen_string_literal: true

class CreateCityContributions < ActiveRecord::Migration[6.1]
  def change
    create_view :city_contributions, materialized: true
    add_index :city_contributions, :completion_id, unique: true
  end
end
