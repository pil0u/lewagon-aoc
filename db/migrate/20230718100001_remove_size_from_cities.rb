# frozen_string_literal: true

class RemoveSizeFromCities < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :cities, :size, :integer }
  end
end
