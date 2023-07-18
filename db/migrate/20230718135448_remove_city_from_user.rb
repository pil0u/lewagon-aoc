# frozen_string_literal: true

class RemoveCityFromUser < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :users, :city_id, :bigint }
  end
end
